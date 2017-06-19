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
        # @param arrays [Array] X-path slectors to select specific fields
        #   from the JSON input.
        # @param order [String or Array] Either a x-path selector string, or
        #   an array containing the order of the +Daru::DataFrame+.
        # @param index [String or Array] Either a x-path selector string, or
        #   an array containing the order of the +Daru::DataFrame+.
        # @param hashes [Hash] X-path slectors to select specific fields
        #   from the JSON input.
        #
        # @note For more information on using x-path selectors, have a look at
        #   the examples {http://www.rubydoc.info/gems/jsonpath/0.5.8 here}.
        #
        # @return A +Daru::DataFrame+ imported from the given JSON input
        #   and x-path selected fields.
        #
        # @example Importing from remote JSON file without x-path fields
        #
        #   url = 'https://data.nasa.gov/resource/2vr3-k9wn.json'
        #   df  = Daru::IO::Importers::JSON.new(url).call
        #
        #   df
        #
        #   #=> #<Daru::DataFrame(202x10)>
        #   #=>           designation discovery_      h_mag      i_deg    moid_au orbit_clas  period_yr ...
        #   #=>         0 419880 (20 2011-01-07       19.7       9.65      0.035     Apollo       4.06 ...
        #   #=>         1 419624 (20 2010-09-17       20.5      14.52      0.028     Apollo          1 ...
        #   #=>         2 414772 (20 2010-07-28         19      23.11      0.333     Apollo       1.31 ...
        #   #=>         3 414746 (20 2010-03-06         18      23.89      0.268       Amor       4.24 ...
        #   #=>         4 407324 (20 2010-07-18       20.7       9.12      0.111     Apollo       2.06 ...
        #   #=>         5 398188 (20 2010-06-03       19.5      13.25      0.024       Aten        0.8 ...
        #   #=>         6 395207 (20 2010-04-25       19.6      27.85      0.007     Apollo       1.96 ...
        #   #=>         7 386847 (20 2010-06-06         18       5.84      0.029     Apollo        2.2 ...
        #   #=>         8 381989 (20 2010-04-28       19.9      26.71      0.104     Apollo       1.56 ...
        #   #=>         9 369454 (20 2010-07-09       19.4      32.78      0.275     Apollo       1.61 ...
        #   #=>        10 365449 (20 2010-07-03       20.3      11.23      0.155       Aten       0.95 ...
        #   #=>        11 365424 (20 2010-05-16       21.9      21.49      0.034       Aten       0.98 ...
        #   #=>        12 356394 (20 2010-08-21       17.4      10.64      0.061     Apollo       2.85 ...
        #   #=>        13 (2015 HF11 2015-04-17       19.2      34.89      0.225       Amor       2.99 ...
        #   #=>        14 (2015 GK50 2015-04-05       20.5      19.07      0.237       Amor       5.39 ...
        #   #=>       ...        ...        ...        ...        ...        ...        ...        ... ...
        #
        # @example Importing from remote JSON response with x-path selectors
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
        #
        #   # Note that the hash x-path selectors like `index`, `RunTime`, etc.
        #   # should be given after normal x-path selectors like that of `name`,
        #   # `season` and `number`.
        #
        #   df
        #
        #   #=> #<Daru::DataFrame(61x4)>
        #   #=>               name     season     number    RunTime
        #   #=>      10 Winter is           1          1         60
        #   #=>      11 The Kingsr          1          2         60
        #   #=>      12  Lord Snow          1          3         60
        #   #=>      13 Cripples,           1          4         60
        #   #=>      14 The Wolf a          1          5         60
        #   #=>      15 A Golden C          1          6         60
        #   #=>      16 You Win or          1          7         60
        #   #=>      17 The Pointy          1          8         60
        #   #=>      18     Baelor          1          9         60
        #   #=>      19 Fire and B          1         10         60
        #   #=>      20 The North           2          1         60
        #   #=>      21 The Night           2          2         60
        #   #=>      22 What is De          2          3         60
        #   #=>      23 Garden of           2          4         60
        #   #=>      24 The Ghost           2          5         60
        #   #=>     ...        ...        ...        ...        ...
        def initialize(input, *arrays, order: nil, index: nil, **hashes)
          super(binding)
          @data       = []
          @auto_order = []
        end

        def call
          json = read_json

          if @hashes.empty?
            if @arrays.size == 1
              @data = get_xpath(json, @arrays.first)
            elsif @arrays.empty?
              parse_without_hash json
            else
              parse_with_array json
            end
          else
            parse_with_array json unless @arrays.empty?
            parse_with_hash json
          end

          @order ||= @auto_order
          Daru::DataFrame.new(@data, order: @order, index: @index)
        end

        private

        def read_json
          # Checks if input is a remote JSON file, local JSON file,
          # API JSON response or JSON string
          if @input.is_a? String
            if @input.start_with?('http') || @input.end_with?('.json')
              # A local or remote JSON file
              ::JSON.parse(open(@input).read)
            else
              # A JSON string
              ::JSON.parse(@input)
            end
          else
            # A JSON response
            @input
          end
        end

        def get_xpath(json, xpath)
          case xpath
          when String
            JsonPath.on(json, xpath)
          when Array, Hash
            xpath
          when nil
            nil
          end
        end

        def parse_with_array(json)
          @data        += @arrays.map { |xpath| get_xpath(json, xpath) }
          @index        = get_xpath(json, @index)
          @auto_order  += @arrays.map { |xpath| xpath.split('..').last }
          @order        = get_xpath(json, @order)
        end

        def parse_with_hash(json)
          @data       += @hashes.values.map { |xpath| get_xpath(json, xpath) }
          @index       = get_xpath(json, @index)
          @auto_order += @hashes.keys
          @order       = get_xpath(json, @order)
        end

        def parse_without_hash(json)
          @data += json
        end
      end
    end
  end
end

require 'daru/io/link'
Daru::DataFrame.register_io_module :from_json, Daru::IO::Importers::JSON
