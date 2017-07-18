require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      class JSON < Base
        Daru::DataFrame.register_io_module :to_json, self

        def initialize(dataframe, path, orient: :index, pretty: false, **jsonpaths)
          optional_gem 'json'
          optional_gem 'jsonpath'

          super(dataframe)
          @path          = path
          @orient        = orient
          @pretty        = pretty
          @jsonpath_hash = jsonpaths.empty? ? nil : jsonpaths
        end

        def call
          @jsonpath_hash ||= @dataframe.vectors.to_a.map { |v| {v => "$..#{v}"} }.reduce(:merge)
          @vectors         = @jsonpath_hash.keys
          @jsonpaths       = process_jsonpath
          @json_content    = process_json_content

          File.open(@path, 'w') { |file| file.write(process_json_string) }
        end

        private

        def process_json_string
          return ::JSON.pretty_generate(@json_content) if @pretty
          ::JSON.generate(@json_content)
        end

        def process_json_content
          return @dataframe.map_vectors(&:to_a) if @orient == :values

          if @orient == :split
            return {
              vectors: @dataframe.vectors.to_a,
              index: @dataframe.index.to_a,
              data: @dataframe.map_vectors(&:to_a)
            }
          end

          @dataframe.map_rows_with_index do |row, idx|
            next init_hash(@jsonpaths, @vectors, row, idx) if @orient == :records
            {idx => init_hash(@jsonpaths, @vectors, row, idx)}
          end
        end

        def process_jsonpath
          @jsonpath_hash.values.map do |x|
            (JsonPath.new(x).path - %w[$ . .. ..{]).map do |y|
              v = y.delete("'.[]")
              next v.to_i if v.to_i.to_s == v
              v.to_sym
            end
          end
        end

        def both_are?(class_name, obj1, obj2)
          obj1.is_a?(class_name) && obj2.is_a?(class_name)
        end

        def deep_merge(source, dest)
          return source if dest.nil?
          return dest if source.nil?

          return dest | source if both_are?(Array, source, dest)
          return source unless both_are?(Hash, source, dest)

          source.each do |src_key, src_value|
            dest[src_key] = dest[src_key] ? deep_merge(src_value, dest[src_key]) : src_value
          end
          dest
        end

        def handle_dynamic_keys(sub_path, idx, row)
          return idx.to_sym if sub_path.to_s == 'index}'
          return row[sub_path.to_s.delete('}').to_sym].to_sym if sub_path.to_s.end_with? '}'
          sub_path
        end

        def init_hash_rec(jsonpaths, hash, jsonpath_key, row, idx)
          jsonpaths[0] = handle_dynamic_keys(jsonpaths[0], idx, row)
          if jsonpaths.count == 1
            hash[jsonpaths.first] = row[jsonpath_key]
          else
            init_hash_rec(jsonpaths[1..-1], hash[jsonpaths.first], jsonpath_key, row, idx)
          end
          hash
        end

        def init_hash(jsonpaths, jsonpath_keys, row, idx)
          first, *rest = jsonpaths.map.with_index do |path, i|
            init_hash_rec(path, Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }, jsonpath_keys[i], row, idx)
          end
          rest.each { |r| first = deep_merge(first, r) }
          first
        end
      end
    end
  end
end
