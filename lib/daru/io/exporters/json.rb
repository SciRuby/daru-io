require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      class JSON < Base
        Daru::DataFrame.register_io_module :to_json, self

        # Exports +Daru::DataFrame+ to a JSON file.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
        # @param path [String] Path of the JSON file where the +Daru::DataFrame+
        #   should be written.
        # @param pretty [Boolean] When set to true, the data is pretty-printed to the
        #   JSON file.
        # @param jsonpaths [Hash] JsonPaths to export given vectors into a compexly nested
        #   JSON structure.
        #
        # @example Writing to a JSON file with pretty print and default orient: :index
        #   df = Daru::DataFrame.new(
        #     [
        #       {name: 'Jon Snow', age: 18, sex: 'Male'},
        #       {name: 'Rhaegar Targaryen', age: 54, sex: 'Male'},
        #       {name: 'Lyanna Stark', age: 36, sex: 'Female'}
        #     ],
        #     order: %i[name age sex],
        #     index: %i[child dad mom]
        #   )
        #
        #   #=> #<Daru::DataFrame(3x3)>
        #   #            name          age       sex
        #   # child   Jon Snow         18       Male
        #   # dad   Rhaegar Ta         54       Male
        #   # mom   Lyanna Sta         36     Female
        #
        #   Daru::IO::Exporters::JSON.new(df, 'filename.json', pretty: true)
        #
        #   #=>
        #   # [
        #   #   {
        #   #     "child": {
        #   #       "sex": "Male",
        #   #       "age": 18,
        #   #       "name": "Jon Snow"
        #   #     }
        #   #   },
        #   #   {
        #   #     "dad": {
        #   #       "sex": "Male",
        #   #       "age": 54,
        #   #       "name": "Rhaegar Targaryen"
        #   #     }
        #   #   },
        #   #   {
        #   #     "mom": {
        #   #       "sex": "Female",
        #   #       "age": 36,
        #   #       "name": "Lyanna Stark"
        #   #     }
        #   #   }
        #   # ]
        #
        # @example Writing to a JSON file with static nested JsonPaths
        #   df = Daru::DataFrame.new(
        #     [
        #       {name: 'Jon Snow', age: 18, sex: 'Male'},
        #       {name: 'Rhaegar Targaryen', age: 54, sex: 'Male'},
        #       {name: 'Lyanna Stark', age: 36, sex: 'Female'}
        #     ],
        #     order: %i[name age sex],
        #     index: %i[child dad mom]
        #   )
        #
        #   #=> #<Daru::DataFrame(3x3)>
        #   #            name          age       sex
        #   # child   Jon Snow         18       Male
        #   # dad   Rhaegar Ta         54       Male
        #   # mom   Lyanna Sta         36     Female
        #
        #   Daru::IO::Exporters::JSON.new(
        #     df,
        #     'filename.json',
        #     orient: :records,
        #     pretty: true,
        #     name: '$.specific.name',
        #     age: '$.common.age',
        #     sex: '$.common.gender'
        #   )
        #
        #   #=>
        #   # [
        #   #   {
        #   #     "common": {
        #   #       "gender": "Male",
        #   #       "age": 18
        #   #     },
        #   #     "specific": {
        #   #       "name": "Jon Snow"
        #   #     }
        #   #   },
        #   #   {
        #   #     "common": {
        #   #       "gender": "Male",
        #   #       "age": 54
        #   #     },
        #   #     "specific": {
        #   #       "name": "Rhaegar Targaryen"
        #   #     }
        #   #   },
        #   #   {
        #   #     "common": {
        #   #       "gender": "Female",
        #   #       "age": 36
        #   #     },
        #   #    "specific": {
        #   #       "name": "Lyanna Stark"
        #   #     }
        #   #   }
        #   # ]
        #
        # @example Writing to a JSON file with dynamic JsonPaths
        #   df = Daru::DataFrame.new(
        #     [
        #       {name: 'Jon Snow', age: 18, sex: 'Male'},
        #       {name: 'Rhaegar Targaryen', age: 54, sex: 'Male'},
        #       {name: 'Lyanna Stark', age: 36, sex: 'Female'}
        #     ],
        #     order: %i[name age sex],
        #     index: %i[child dad mom]
        #   )
        #
        #   #=> #<Daru::DataFrame(3x3)>
        #   #            name          age       sex
        #   # child   Jon Snow         18       Male
        #   # dad   Rhaegar Ta         54       Male
        #   # mom   Lyanna Sta         36     Female
        #
        #   Daru::IO::Exporters::JSON.new(
        #     df,
        #     'filename.json',
        #     orient: :records,
        #     pretty: true,
        #     age: '$.{name}.age',
        #     sex: '$.{name}.gender'
        #   )
        #
        #   #=>
        #   # [
        #   #   {
        #   #     "Jon Snow": {
        #   #       "gender": "Male",
        #   #       "age": 18
        #   #     }
        #   #   },
        #   #   {
        #   #     "Rhaegar Targaryen": {
        #   #       "gender": "Male",
        #   #       "age": 54
        #   #     }
        #   #   },
        #   #   {
        #   #     "Lyanna Stark": {
        #   #     "gender": "Female",
        #   #     "age": 36
        #   #     }
        #   #   }
        #   # ]
        def initialize(dataframe, path, pretty: false, **jsonpaths)
          require 'json'
          optional_gem 'jsonpath'

          super(dataframe)
          @path          = path
          @pretty        = pretty
          @jsonpath_hash = jsonpaths.empty? ? nil : jsonpaths
        end

        def call
          @jsonpath_hash ||= @dataframe.vectors.to_a.map { |v| {v => "$.#{v}"} }.reduce(:merge)
          @vectors         = @jsonpath_hash.keys
          @jsonpaths       = process_jsonpath
          @json_content    = @dataframe.map_rows_with_index do |row, idx|
            init_hash(@jsonpaths, @vectors, row, idx)
          end

          File.open(@path, 'w') do |file|
            file.write(::JSON.send(@pretty ? :pretty_generate : :generate, @json_content))
          end
        end

        private

        def process_json_string
          return ::JSON.pretty_generate(@json_content) if @pretty
          ::JSON.generate(@json_content)
        end

        def process_jsonpath
          @jsonpath_hash.values.map do |x|
            (JsonPath.new(x).path - %w[$ ${ . .. ..{]).map do |y|
              v = y.delete("'.[]{")
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
          if sub_path.to_s.end_with? '}'
            val = row[sub_path.to_s.delete('}').to_sym]
            return val.to_i if val.to_i.to_s == val
            return val.to_sym
          end
          sub_path
        end

        def init_hash_rec(jsonpaths, hash, jsonpath_key, row, idx)
          key = handle_dynamic_keys(jsonpaths[0], idx, row)
          if jsonpaths.count == 1
            hash[key] = jsonpath_key == :index ? idx : row[jsonpath_key]
          else
            init_hash_rec(jsonpaths[1..-1], hash[key], jsonpath_key, row, idx)
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
