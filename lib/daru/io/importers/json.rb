require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # JSON Importer Class, that extends `from_json` and `read_json` methods
      # to `Daru::DataFrame`
      class JSON < Base
        Daru::DataFrame.register_io_module :from_json, self
        Daru::DataFrame.register_io_module :read_json, self

        # Checks for required gem dependencies of JSON Importer
        def initialize
          require 'open-uri'
          require 'json'
          optional_gem 'jsonpath'
        end

        # Reads data from a json file / remote json response
        #
        # @param path [String] Local / Remote path to json file, where the dataframe is to be imported
        #   from.
        #
        # @return [Daru::IO::Importers::JSON]
        #
        # @example Reading from simply nested remote json response
        #   url = 'https://data.nasa.gov/resource/2vr3-k9wn.json'
        #   simple_read_instance = Daru::IO::Importers::JSON.read(url)
        #
        # @example Reading from complexy nested remote json response
        #   url = 'http://api.tvmaze.com/singlesearch/shows?q=game-of-thrones&embed=episodes'
        #   complex_read_instance = Daru::IO::Importers::JSON.read(url)
        def read(path)
          @file_data = ::JSON.parse(open(path).read)
          @json      = @file_data
          self
        end

        # Loads from a Ruby structure of Hashes and / or Arrays
        #
        # @param instance [Hash or Array] A simple / complexly nested JSON structure
        #
        # @return [Daru::IO::Importers::JSON]
        #
        # @example Loading from Ruby Hash of Arrays
        #   from_instance = Daru::IO::Importers::JSON.from({x: [1,4], y: [2,5], z: [3, 6]})
        def from(instance)
          @file_data = instance
          @json      = @file_data.is_a?(String) ? ::JSON.parse(@file_data) : @file_data
          self
        end

        # Imports a `Daru::DataFrame` from a JSON Importer instance
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
        # @return [Daru::DataFrame]
        #
        # @note For more information on using JSON-path selectors, have a look at
        #   the explanations {http://www.rubydoc.info/gems/jsonpath/0.5.8 here}
        #   and {http://goessner.net/articles/JsonPath/ here}.
        #
        # @example Importing without jsonpath selectors
        #   df = simple_read_instance.call
        #
        #   #=> #<Daru::DataFrame(202x10)>
        #   #    designation discovery_      h_mag      i_deg    moid_au orbit_clas  period_yr ...
        #   #  0 419880 (20 2011-01-07       19.7       9.65      0.035     Apollo       4.06  ...
        #   #  1 419624 (20 2010-09-17       20.5      14.52      0.028     Apollo          1  ...
        #   #  2 414772 (20 2010-07-28         19      23.11      0.333     Apollo       1.31  ...
        #   # ...        ...        ...        ...        ...        ...        ...       ...  ...
        #
        # @example Importing with jsonpath selectors
        #   df = complex_read_instance.call(
        #     "$.._embedded..episodes..name",
        #     "$.._embedded..episodes..season",
        #     "$.._embedded..episodes..number",
        #     index: (10..70).to_a,
        #     RunTime: "$.._embedded..episodes..runtime"
        #   )
        #
        #   #=> #<Daru::DataFrame(61x4)>
        #   #         name           season     number    RunTime
        #   #   10 Winter is           1          1         60
        #   #   11 The Kingsr          1          2         60
        #   #   12  Lord Snow          1          3         60
        #   #  ...        ...        ...        ...        ...
        #
        # @example Importing from `from` method
        #   df = from_instance.call
        #
        #   #=> #<Daru::DataFrame(2x3)>
        #   #       x   y   z
        #   #   0   1   2   3
        #   #   1   4   5   6
        def call(*columns, order: nil, index: nil, **named_columns)
          init_opts(*columns, order: order, index: index, **named_columns)
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
