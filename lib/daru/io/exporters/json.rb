require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      # JSON Exporter Class, that extends **to_json** method to **Daru::DataFrame**
      # instance variables
      class JSON < Base
        Daru::DataFrame.register_io_module :to_json, self

        ORIENT_TYPES = %i[index records split values].freeze

        # Exports **Daru::DataFrame** to a JSON file.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
        # @param path [String] Path of the JSON file where the **Daru::DataFrame**
        #   should be written.
        # @param orient [Symbol] Setting to export the data in a specific structure.
        #   Defaults to `:records`.
        #
        #   - `:values` : Returns a 2D array containing the data in the DataFrame.
        #   - `:split`  : Returns a `Hash`, containing keys `:vectors`, `:index` and `:data`.
        #   - `:records` : Returns an Array of Hashes with given JsonPath content.
        #   - `:index`   : Returns a Hash of Hashes with index values as keys,
        #     and given JsonPath content as values.
        #
        #   After choosing an `:orient` option, the JSON content can be manipulated before
        #   writing into the JSON file, by providing a block.
        #
        # @param pretty [Boolean] When set to true, the data is pretty-printed to the
        #   JSON file.
        # @param jsonpaths [Hash] JsonPaths to export given vectors into a compexly nested
        #   JSON structure.
        #
        # @example Writing to a JSON file with default orient: :records
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
        #   Daru::IO::Exporters::JSON.new(df, 'filename.json', orient: :records, pretty: true).call
        #
        #   #=>
        #   # [
        #   #   {
        #   #     "sex": "Male",
        #   #     "age": 18,
        #   #     "name": "Jon Snow"
        #   #   },
        #   #   {
        #   #     "sex": "Male",
        #   #     "age": 54,
        #   #     "name": "Rhaegar Targaryen"
        #   #   },
        #   #   {
        #   #     "sex": "Female",
        #   #     "age": 36,
        #   #     "name": "Lyanna Stark"
        #   #   }
        #   # ]
        #
        # @example Writing to a JSON file with orient: :index
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
        #   Daru::IO::Exporters::JSON.new(df, 'filename.json', pretty: true).call
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
        # @example Writing to a JSON file with orient: :values
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
        #   Daru::IO::Exporters::JSON.new(df, 'filename.json', orient: :values, pretty: true).call
        #
        #   #=>
        #   # [
        #   #   [
        #   #     "Jon Snow",
        #   #     "Rhaegar Targaryen",
        #   #     "Lyanna Stark"
        #   #   ],
        #   #   [
        #   #     18,
        #   #     54,
        #   #     36
        #   #   ],
        #   #   [
        #   #     "Male",
        #   #     "Male",
        #   #     "Female"
        #   #   ]
        #   # ]
        #
        # @example Writing to a JSON file with orient: :split
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
        #   Daru::IO::Exporters::JSON.new(df, 'filename.json', orient: :split, pretty: true).call
        #
        #   #=>
        #   # {
        #   #   "vectors": [
        #   #     "name",
        #   #     "age",
        #   #     "sex"
        #   #   ],
        #   #   "index": [
        #   #     "child",
        #   #     "dad",
        #   #     "mom"
        #   #   ],
        #   #   "data": [
        #   #     [
        #   #       "Jon Snow",
        #   #       "Rhaegar Targaryen",
        #   #       "Lyanna Stark"
        #   #     ],
        #   #     [
        #   #       18,
        #   #       54,
        #   #       36
        #   #     ],
        #   #     [
        #   #       "Male",
        #   #       "Male",
        #   #       "Female"
        #   #     ]
        #   #   ]
        #   # }
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
        #   ).call
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
        #   ).call
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
        #
        # @example Writing to a JSON file with orient: :index and block
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
        #   Daru::IO::Exporters::JSON.new(df, 'filename.json', orient: :index, pretty: true) do |json|
        #     json.map { |j| [j.keys.first, j.values.first] }.to_h
        #   end.call
        #
        #   #=>
        #   # {
        #   #   "child": {
        #   #     "sex": "Male",
        #   #     "age": 18,
        #   #     "name": "Jon Snow"
        #   #   },
        #   #   "dad": {
        #   #     "sex": "Male",
        #   #     "age": 54,
        #   #     "name": "Rhaegar Targaryen"
        #   #   },
        #   #   "mom": {
        #   #     "sex": "Female",
        #   #     "age": 36,
        #   #     "name": "Lyanna Stark"
        #   #   }
        #   # }
        def initialize(dataframe, path, orient: :records, pretty: false, **jsonpaths, &block)
          require 'json'
          optional_gem 'jsonpath'

          super(dataframe)
          @path          = path
          @block         = block
          @orient        = orient
          @pretty        = pretty
          @jsonpath_hash = jsonpaths.empty? ? nil : jsonpaths

          validate_params
        end

        def call
          @jsonpath_hash ||= @dataframe.vectors.to_a.map { |v| {v => "$.#{v}"} }.reduce(:merge)
          @vectors         = @jsonpath_hash.keys
          @jsonpaths       = process_jsonpath
          @json_content    = process_json_content
          @json_content    = @block.call(@json_content) if @block

          File.open(@path, 'w') do |file|
            file.write(::JSON.send(@pretty ? :pretty_generate : :generate, @json_content))
          end
        end

        private

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
          jsonpaths.map.with_index do |path, i|
            init_hash_rec(path, Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }, jsonpath_keys[i], row, idx)
          end.reduce { |cumulative, current| deep_merge(cumulative, current) }
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
            (JsonPath.new(x).path - %w[$ ${ . .. ..{]).map do |y|
              v = y.delete("'.[]{")
              next v.to_i if v.to_i.to_s == v
              v.to_sym
            end
          end
        end

        def validate_params
          raise ArgumentError, "Invalid orient option '#{@orient}' given." unless ORIENT_TYPES.include?(@orient)
        end
      end
    end
  end
end
