require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      class JSON < Base
        Daru::DataFrame.register_io_module :to_json, self

        def initialize(dataframe, path, **jsonpaths)
          require 'json'
          optional_gem 'jsonpath'

          super(dataframe)
          @path          = path
          @jsonpath_hash = jsonpaths.empty? ? nil : jsonpaths
        end

        def call
          @jsonpath_hash ||= @dataframe.vectors.to_a.map { |v| {v => "$..#{v}"} }.reduce(:merge)
          @vectors   = @jsonpath_hash.keys
          @jsonpaths = process_jsonpath

          @nested_hash = @dataframe.map_rows { |row| init_hash(@jsonpaths, @vectors, row) }
          File.open(@path, 'w') { |file| file.write(::JSON.pretty_generate(@nested_hash)) }
        end

        private

        def process_jsonpath
          @jsonpath_hash.values.map do |x|
            (JsonPath.new(x).path - %w[$ . ..]).map do |y|
              v = y.delete("'[]")
              next v.to_i if v.to_i.to_s == v
              v.to_sym
            end
          end
        end

        def deep_merge(source, dest)
          return source if dest.nil?
          return dest if source.nil?

          both_array = source.is_a?(Array) && dest.is_a?(Array)
          return dest | source if both_array

          both_hash = source.is_a?(Hash) && dest.is_a?(Hash)
          return source unless both_hash

          source.each do |src_key, src_value|
            dest[src_key] = dest[src_key] ? deep_merge(src_value, dest[src_key]) : src_value
          end
          dest
        end

        def init_hash_rec(jsonpaths, hash, i, jsonpath_keys, row)
          if jsonpaths.count == 1
            hash[jsonpaths.first] = row[i]
          else
            init_hash_rec(jsonpaths[1..-1], hash[jsonpaths.first], i, jsonpath_keys, row)
          end
          hash
        end

        def init_hash(jsonpaths, jsonpath_keys, row)
          first, *rest = jsonpaths.map.with_index do |path, i|
            init_hash_rec(path, Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }, i, jsonpath_keys, row)
          end
          rest.each { |r| first = deep_merge(first, r) }
          first
        end
      end
    end
  end
end
