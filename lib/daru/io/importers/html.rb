require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # HTML Importer Class, that extends `read_html` method to `Daru::DataFrame`
      #
      # @note
      #   Please note that this module works only for static table elements on a
      #   HTML page, and won't work in cases where the data is being loaded into
      #   the HTML table by inline Javascript.
      class HTML < Base
        Daru::DataFrame.register_io_module :read_html, self

        # Checks for required gem dependencies of HTML Importer
        def initialize
          require 'open-uri'
          optional_gem 'nokogiri'
        end

        # Reads from a html file / website
        #
        # @!method self.read(path)
        #
        # @param path [String] Website URL / path to HTML file, where the
        #   DataFrame is to be imported from.
        #
        # @return [Daru::IO::Importers::HTML]
        #
        # @example Reading from a website url file
        #   instance = Daru::IO::Importers::HTML.read('http://www.moneycontrol.com/')
        def read(path)
          @file_data = Nokogiri.parse(open(path).read)
          self
        end

        # Imports Array of `Daru::DataFrame`s from a HTML Importer instance
        #
        # @param match [String] A `String` to match and choose a particular table(s)
        #   from multiple tables of a HTML page.
        # @param index [Array or Daru::Index or Daru::MultiIndex] If given, it
        #   overrides the parsed index. Have a look at `:index` option, at
        #   {http://www.rubydoc.info/gems/daru/0.1.5/Daru%2FDataFrame:initialize
        #   Daru::DataFrame#initialize}
        # @param order [Array or Daru::Index or Daru::MultiIndex] If given, it
        #   overrides the parsed order. Have a look at `:order` option
        #   [here](http://www.rubydoc.info/gems/daru/0.1.5/Daru%2FDataFrame:initialize)
        # @param name [String] As `name` of the imported `Daru::DataFrame` isn't
        #   parsed automatically by the module, users can set the name attribute to
        #   their `Daru::DataFrame` manually, through this option.
        #
        #   See `:name` option
        #   [here](http://www.rubydoc.info/gems/daru/0.1.5/Daru%2FDataFrame:initialize)
        #
        # @return [Array<Daru::DataFrame>]
        #
        # @example Importing with matching tables
        #   list_of_dfs = instance.call(match: 'Sun Pharma')
        #   list_of_dfs.count
        #   #=> 4
        #
        #   df = list_of_dfs.first
        #
        #   # As the website keeps changing everyday, the output might not be exactly
        #   # the same as the one obtained below. Nevertheless, a Daru::DataFrame
        #   # should be obtained (as long as 'Sun Pharma' is there on the website).
        #
        #   #=> <Daru::DataFrame(5x4)>
        #   #        Company      Price     Change Value (Rs
        #   #   0 Sun Pharma     502.60     -65.05   2,117.87
        #   #   1   Reliance    1356.90      19.60     745.10
        #   #   2 Tech Mahin     379.45     -49.70     650.22
        #   #   3        ITC     315.85       6.75     621.12
        #   #   4       HDFC    1598.85      50.95     553.91
        def call(match: nil, order: nil, index: nil, name: nil)
          @match   = match
          @options = {name: name, index: index, order: order}

          @file_data
            .search('table')
            .map { |table| parse_table(table) }
            .compact
            .keep_if { |table| satisfy_dimension(table) && search(table) }
            .map { |table| decide_values(table, @options) }
            .map { |table| table_to_dataframe(table) }
        end

        private

        # Allows user to override the scraped order / index / data
        def decide_values(scraped_val, user_val)
          scraped_val.merge(user_val) { |_key, scraped, user| user || scraped }
        end

        # Splits headers (all th tags) into order and index. Wherein,
        # Order : All <th> tags on first proper row of HTML table
        # index : All <th> tags on first proper column of HTML table
        def parse_hash(headers, size, headers_size)
          headers_index = headers.find_index { |x| x.count == headers_size }
          order = headers[headers_index]
          order_index = order.count - size
          order = order[order_index..-1]
          indice = headers[headers_index+1..-1].flatten
          indice = nil if indice.to_a.empty?
          [order, indice]
        end

        def parse_table(table)
          headers, headers_size = scrape_tag(table,'th')
          data, size = scrape_tag(table, 'td')
          data = data.keep_if { |x| x.count == size }
          order, indice = parse_hash(headers, size, headers_size) if headers_size >= size
          return unless (indice.nil? || indice.count == data.count) && !order.nil? && order.count>0
          {data: data.compact, index: indice, order: order}
        end

        def scrape_tag(table, tag)
          arr  = table.search('tr').map { |row| row.search(tag).map { |val| val.text.strip } }
          size = arr.map(&:count).max
          [arr, size]
        end

        def satisfy_dimension(table)
          return false if @options[:order] && table[:data].first.size != @options[:order].size
          return false if @options[:index] && table[:data].size != @options[:index].size
          true
        end

        def search(table)
          @match.nil? ? true : table.to_s.include?(@match)
        end

        def table_to_dataframe(table)
          Daru::DataFrame.rows(
            table[:data],
            index: table[:index],
            order: table[:order],
            name: table[:name]
          )
        end
      end
    end
  end
end
