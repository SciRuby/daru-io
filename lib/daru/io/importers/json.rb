require 'daru'
require 'daru/io/base'

require 'json'
require 'open-uri'
require 'jsonpath'

module Daru
  module IO
    module Importers
      class JSON < Base
        # Imports a +Daru::DataFrame+ from a JSON file or response.
        #
        # @param input [String or JSON response] Either the path to local /
        #   remote JSON file, or JSON response (which can be a
        #   nested +Hash+ or +Array of Hashes+) from any API.
        #
        # @param columns [Array] JSON-path slectors to select specific fields
        #   from the JSON input.
        # @param order [String or Array] Either a JSON-path selector string, or
        #   an array containing the order of the +Daru::DataFrame+.
        # @param index [String or Array] Either a JSON-path selector string, or
        #   an array containing the order of the +Daru::DataFrame+.
        # @param named_columns [Hash] JSON-path slectors to select specific fields
        #   from the JSON input.
        #
        # @note For more information on using JSON-path selectors, have a look at
        #   the explanations {http://www.rubydoc.info/gems/jsonpath/0.5.8 here}
        #   and {http://goessner.net/articles/JsonPath/ here}.
        #
        # @return A +Daru::DataFrame+ imported from the given JSON input
        #   and x-path selected fields.
        #
        # @example Importing from remote JSON file without json-path selectors
        #
        #   url = 'https://data.nasa.gov/resource/2vr3-k9wn.json'
        #   df  = Daru::IO::Importers::JSON.new(url).call
        #
        #   df
        #
        #   #=> #<Daru::DataFrame(202x10)>
        #   #    designation discovery_      h_mag      i_deg    moid_au orbit_clas  period_yr ...
        #   #  0 419880 (20 2011-01-07       19.7       9.65      0.035     Apollo       4.06  ...
        #   #  1 419624 (20 2010-09-17       20.5      14.52      0.028     Apollo          1  ...
        #   #  2 414772 (20 2010-07-28         19      23.11      0.333     Apollo       1.31  ...
        #   # ...        ...        ...        ...        ...        ...        ...       ...  ...
        #
        # @example Importing from remote JSON response with json-path selectors
        #
        #   url = 'http://api.tvmaze.com/singlesearch/shows?q=game-of-thrones&embed=episodes'
        #   df  = Daru::IO::Importers::JSON.new(url,
        #             "$.._embedded..episodes..name",
        #           "$.._embedded..episodes..season",
        #           "$.._embedded..episodes..number",
        #            index: (10..70).to_a,
        #            RunTime: "$.._embedded..episodes..runtime"
        #         ).call
        #
        #   df
        #
        #   #=> #<Daru::DataFrame(61x4)>
        #   #         name           season     number    RunTime
        #   #   10 Winter is           1          1         60
        #   #   11 The Kingsr          1          2         60
        #   #   12  Lord Snow          1          3         60
        #   #  ...        ...        ...        ...        ...
        def initialize(input, *columns, order: nil, index: nil, **named_columns)
          super(binding)
        end

        def call
          @json    = read_json
          @data    = fetch_data
          @index   = at_jsonpath(@index)
          @order   = at_jsonpath(@order)
          @order ||= @columns.map { |col| col.split('.').last } + @named_columns.keys
          # Alternative : @order ||= (0..@columns.count-1).to_a + @named_columns.keys

          Daru::DataFrame.new @data, order: @order, index: @index
        end

        private

        def read_json
          return @input unless @input.is_a?(String)
          return ::JSON.parse(@input) unless @input.start_with?('http') || @input.end_with?('.json')
          ::JSON.parse(open(@input).read)
        end

        def at_jsonpath(jsonpath)
          jsonpath.is_a?(String) ? JsonPath.on(@json, jsonpath) : jsonpath
        end

        def fetch_data
          return @json if @columns.empty? && @named_columns.empty?
          return at_jsonpath(@columns.first) if @columns.size == 1 && @named_columns.empty?
          data_columns = @columns + @named_columns.values
          data_columns.map { |col| at_jsonpath(col) }
        end
      end
    end
  end
end

require 'daru/io/link'
Daru::DataFrame.register_io_module :from_json, Daru::IO::Importers::JSON
