require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      # JSON Exporter Class, that extends `to_json`, `to_json_string` and `write_json` methods
      # to `Daru::DataFrame` instance variables
      class JSON < Base
        Daru::DataFrame.register_io_module :to_json, self
        Daru::DataFrame.register_io_module :to_json_string, self
        Daru::DataFrame.register_io_module :write_json, self

        ORIENT_TYPES = %i[index records split values].freeze

        # Initializes a JSON Exporter instance.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
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
        # @example Initializing a JSON Exporter instance
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
        #   json_exporter = Daru::IO::Exporters::JSON
        #
        #   index_instance = json_exporter.new(df, orient: :index, pretty: true)
        #   records_instance = json_exporter.new(df,orient: :records, pretty: true)
        #   values_instance = json_exporter.new(df, orient: :values, pretty: true)
        #   split_instance = json_exporter.new(df, orient: :split, pretty: true)
        #   static_jsonpath_instance = json_exporter.new(
        #       df, pretty: true, name: '$.specific.name', age: '$.common.age', sex: '$.common.gender'
        #   )
        #   dynamic_jsonpath_instance = json_exporter.new(
        #       df, pretty: true, age: '$.{name}.age', sex: '$.{name}.gender'
        #   )
        #   block_instance = json_exporter.new(df, orient: :index, pretty: true) do |json|
        #     json.map { |j| [j.keys.first, j.values.first] }.to_h
        #   end
        def initialize(dataframe, orient: :records, pretty: false, **jsonpaths, &block)
          require 'json'
          optional_gem 'jsonpath'

          super(dataframe)
          @block         = block
          @orient        = orient
          @pretty        = pretty
          @jsonpath_hash = jsonpaths.empty? ? nil : jsonpaths

          validate_params
        end

        # Exports a JSON Exporter instance to a file-writable String.
        #
        # @return [String] A file-writable string
        #
        # @example Getting a file-writable string with default orient: :records
        #   records_instance.to_s
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
        # @example Getting a file-writable string with orient: :index
        #   index_instance.to_s
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
        # @example Getting a file-writable string with orient: :values
        #   values_instance.to_s
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
        # @example Getting a file-writable string with orient: :split
        #   split_instance.to_s
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
        # @example Getting a file-writable string with static nested JsonPaths
        #   static_jsonpath_instance.to_s
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
        # @example Getting a file-writable string with dynamic JsonPaths
        #   dynamic_jsonpath_instance.to_s
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
        # @example Getting a file-writable string with orient: :index and block
        #   block_instance.to_s
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
        def to_s
          super
        end

        # Exports a JSON Exporter instance to a Ruby structure comprising of Arrays & Hashes.
        #
        # @return [Array or Hash]
        #
        # @example With default orient: :records
        #   records_instance.to
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
        # @example With orient: :index
        #   index_instance.to
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
        # @example With orient: :values
        #   values_instance.to
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
        # @example With orient: :split
        #   split_instance.to
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
        # @example With static nested JsonPaths
        #   static_jsonpath_instance.to
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
        # @example With dynamic JsonPaths
        #   dynamic_jsonpath_instance.to
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
        # @example With orient: :index and block
        #   block_instance.to
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
        def to
          @jsonpath_hash ||= @dataframe.vectors.to_a.map { |v| {v => "$.#{v}"} }.reduce(:merge)
          @vectors         = @jsonpath_hash.keys
          @jsonpaths       = process_jsonpath
          @json_content    = process_json_content
          @json_content    = @block.call(@json_content) if @block

          @json_content
        end

        # Exports a JSON Exporter instance to a json file.
        #
        # @param path [String] Path of JSON file where the dataframe is to be saved
        #
        # @example Writing a JSON Exporter instance to a JSON file
        #   index_instance.write('index.json')
        #   split_instance.write('split.json')
        #   values_instance.write('values.json')
        #   records_instance.write('records.json')
        #   static_jsonpath_instance.write('static.json')
        #   dynamic_jsonpath_instance.write('dynamic.json')
        #   block_instance.write('block.json')
        def write(path)
          File.open(path, 'w') do |file|
            file.write(::JSON.send(@pretty ? :pretty_generate : :generate, to))
          end
          true
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
