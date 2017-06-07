require 'daru/io/importers/linkages/html'

module Daru
  module IO
    module Importers
      class HTML
        def initialize(path, match: nil, order: nil, index: nil, name: nil)
          @path = path
          @match = match
          @options = {name: name, order: order, index: index}
        end

        def load
          require 'mechanize'
          page = Mechanize.new.get(@path)
          page.search('table').map { |table| parse_table table }
              .keep_if { |table| search table }
              .compact
              .map { |table| decide_values table, @options }
              .map { |table| table_to_dataframe table }
        rescue LoadError
          raise_error
        end

        def self.raise_error
          raise 'Install the mechanize gem version 2.7.5 with `gem install mechanize`,'\
          ' for using the from_html function.'
        end

        private

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

        def search(table)
          @match.nil? ? true : (table.to_s.include? @match)
        end

        # Allows user to override the scraped order / index / data
        def decide_values(scraped_val={}, user_val={})
          %I[data index name order].each do |key|
            user_val[key] ||= scraped_val[key]
          end
          user_val
        end

        def table_to_dataframe(table)
          Daru::DataFrame.rows table[:data],
            index: table[:index],
            order: table[:order],
            name: table[:name]
        end
      end
    end
  end
end
