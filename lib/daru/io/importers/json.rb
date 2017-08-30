require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # JSON Importer Class, that extends `from_json` and `read_json` methods
      # to `Daru::DataFrame`
      class JSON < Base
        Daru::DataFrame.register_io_module :from_json, self
        Daru::DataFrame.register_io_module :read_json, self

        # Initializes a JSON Importer instance
        #
        # @param columns [Array] JSON-path slectors to select specific fields
        #   from the JSON input.
        # @param order [String or Array] Either a JSON-path selector string, or
        #   an array containing the order of the `Daru::DataFrame`.
        # @param index [String or Array] Either a JSON-path selector string, or
        #   an array containing the order of the `Daru::DataFrame`.
        # @param named_columns [Hash] JSON-path slectors to select specific fields
        #   from the JSON input.
        #
        # @note For more information on using JSON-path selectors, have a look at
        #   the explanations {http://www.rubydoc.info/gems/jsonpath/0.5.8 here}
        #   and {http://goessner.net/articles/JsonPath/ here}.
        #
        # @example Initializing without json-path selectors
        #   default_instance = Daru::IO::Importers::JSON.new
        #
        # @example Initializing with json-path selectors
        #   jsonpath_instance = Daru::IO::Importers::JSON.new(
        #     "$.._embedded..episodes..name",
        #     "$.._embedded..episodes..season",
        #     "$.._embedded..episodes..number",
        #     index: (10..70).to_a,
        #     RunTime: "$.._embedded..episodes..runtime"
        #   )
        def initialize
          require 'open-uri'
          require 'json'
          optional_gem 'jsonpath'
        end

        # Imports a `Daru::DataFrame` from an Avro Importer instance and JSON structure
        #   of Arrays and Hashes
        #
        # @param instance [Array or Hash] A JSON structure, comprising of Arrays and Hashes.
        #
        # @return [Daru::DataFrame]
        #
        # @example Importing from a JSON structure
        #   df = default_instance.from({a: [1,3], b: [2,4]})
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #        a   b
        #   #  0     1   2
        #   #  1     3   4

        # Imports a `Daru::DataFrame` from a JSON Importer instance and json file
        #
        # @param path [String] Local / Remote path to JSON file or API response.
        #
        # @return [Daru::DataFrame]
        #
        # @example Importing from simple json response of remote file
        #   df = default_instance.read('https://data.nasa.gov/resource/2vr3-k9wn.json')
        #
        #   #=> #<Daru::DataFrame(202x10)>
        #   #    designation discovery_      h_mag      i_deg    moid_au orbit_clas  period_yr ...
        #   #  0 419880 (20 2011-01-07       19.7       9.65      0.035     Apollo       4.06  ...
        #   #  1 419624 (20 2010-09-17       20.5      14.52      0.028     Apollo          1  ...
        #   #  2 414772 (20 2010-07-28         19      23.11      0.333     Apollo       1.31  ...
        #   # ...        ...        ...        ...        ...        ...        ...       ...  ...
        #
        # @example Importing from complex json response of remote file
        #   df = jsonpath_instance.read('http://api.tvmaze.com/singlesearch/shows?q=game-of-thrones&embed=episodes')
        #
        #   #=> #<Daru::DataFrame(61x4)>
        #   #         name           season     number    RunTime
        #   #   10 Winter is           1          1         60
        #   #   11 The Kingsr          1          2         60
        #   #   12  Lord Snow          1          3         60
        #   #  ...        ...        ...        ...        ...
        def read(path)
          @file_string = open(path).read
          self
        end

        def from(instance)
          @file_string = instance
          self
        end

        def call(*columns, order: nil, index: nil, **named_columns)
          init_opts(*columns, order: order, index: index, **named_columns)

          @json    = @file_string.is_a?(String) ? ::JSON.parse(@file_string) : @file_string
          @data    = fetch_data
          @index   = at_jsonpath(@index)
          @order   = at_jsonpath(@order)
          @order ||= Array.new(@columns.count) { |x| x } + @named_columns.keys

          Daru::DataFrame.new(@data, order: @order, index: @index)
        end

        private

        def at_jsonpath(jsonpath)
          jsonpath.is_a?(String) ? JsonPath.on(@json, jsonpath) : jsonpath
        end

        def fetch_data
          return @json if @columns.empty? && @named_columns.empty?

          # If only one unnamed column is provided without any named_columns,
          # entire dataset is assumed to reside in that JSON-path.
          return at_jsonpath(@columns.first) if @columns.size == 1 && @named_columns.empty?
          data_columns = @columns + @named_columns.values
          data_columns.map { |col| at_jsonpath(col) }
        end

        def init_opts(*columns, order: nil, index: nil, **named_columns)
          @columns       = columns
          @order         = order
          @index         = index
          @named_columns = named_columns

          validate_params
        end

        def validate_params
          return if @order.nil? || @named_columns.empty?

          raise ArgumentError,
            'Do not pass on order and named columns together, at the same '\
            'function call. Please use only order or only named_columns.'
        end
      end
    end
  end
end
