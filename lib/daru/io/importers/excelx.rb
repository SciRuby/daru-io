require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # Excelx Importer Class, that handles .xlsx files in the Excel Importer
      class Excelx < Base
        # Initializes an Excelx Importer instance
        #
        # @param skiprows [Integer] Skips the first `:skiprows` number of rows from the
        #   sheet being parsed.
        # @param skipcols [Integer] Skips the first `:skipcols` number of columns from the
        #   sheet being parsed.
        # @param order [Boolean] Defaults to true. When set to true, first row of the
        #   given sheet is used as the order of the Daru::DataFrame and data of
        #   the Dataframe consists of the remaining rows.
        # @param index [Boolean] Defaults to false. When set to true, first column of the
        #   given sheet is used as the index of the Daru::DataFrame and data of
        #   the Dataframe consists of the remaining columns.
        #
        #   When set to false, a default order (0 to n-1) is chosen for the DataFrame,
        #   and the data of the DataFrame consists of all rows in the sheet.
        #
        # @example Initializing with options
        #   normal_instance = Daru::IO::Importers::Excelx.new(sheet: 'Example Stock Counts')
        #   headers_instance = Daru::IO::Importers::Excelx.new(sheet: 'Example Stock Counts', headers: false)
        def initialize(sheet: 0, order: true, index: false, skiprows: 0, skipcols: 0)
          optional_gem 'roo', '~> 2.7.0'

          @sheet    = sheet
          @order    = order
          @index    = index
          @skiprows = skiprows
          @skipcols = skipcols
        end

        # Imports a `Daru::DataFrame` from an Excelx Importer instance and xlsx file
        #
        # @param path [String] Local / remote path to xlsx file
        #
        # @return [Daru::DataFrame]
        #
        # @example Importing from a local file
        #   df = normal_instance.read("spec/fixtures/excelx/Stock-counts-sheet.xlsx")
        #
        #   #=> <Daru::DataFrame(15x7)>
        #   #           Status Stock coun  Item code        New Descriptio Stock coun Offset G/L
        #   #     0          H          1        nil        nil New stock  2014-08-01        nil
        #   #     1        nil          1  IND300654          2 New stock  2014-08-01      51035
        #   #     2        nil          1   IND43201          5 New stock  2014-08-01      51035
        #   #     3        nil          1   OUT30045          3 New stock  2014-08-01      51035
        #   #    ...       ...        ...     ...           ...     ...       ...           ...
        #
        # @example Importing from a remote URL
        #   df = normal_instance.read('https://www.exact.com/uk/images/downloads/getting-started-excel-sheets/Stock-counts-sheet.xlsx')
        #
        #   #=> <Daru::DataFrame(15x7)>
        #   #           Status Stock coun  Item code        New Descriptio Stock coun Offset G/L
        #   #     0          H          1        nil        nil New stock  2014-08-01        nil
        #   #     1        nil          1  IND300654          2 New stock  2014-08-01      51035
        #   #     2        nil          1   IND43201          5 New stock  2014-08-01      51035
        #   #     3        nil          1   OUT30045          3 New stock  2014-08-01      51035
        #   #    ...       ...        ...     ...           ...     ...       ...           ...
        #
        # @example Importing without headers
        #   df = headers_instance.read('spec/fixtures/excelx/Stock-counts-sheet.xlsx')
        #
        #   #=> <Daru::DataFrame(16x7)>
        #   #                0           1          2          3          4          5        6
        #   #     0      Status Stock coun  Item code        New Descriptio Stock coun Offset G/L
        #   #     1          H          1        nil        nil New stock  2014-08-01        nil
        #   #     2        nil          1  IND300654          2 New stock  2014-08-01      51035
        #   #     3        nil          1   IND43201          5 New stock  2014-08-01      51035
        #   #     4        nil          1   OUT30045          3 New stock  2014-08-01      51035
        #   #    ...       ...        ...     ...           ...     ...       ...           ...
        def read(path)
          book      = Roo::Excelx.new(path)
          worksheet = book.sheet(@sheet)

          @data     = strip_html_tags(skip_data(worksheet.to_a, @skiprows, @skipcols))
          @index    = process_index
          @order    = process_order || (0..@data.first.length-1)
          @data     = process_data

          Daru::DataFrame.rows(@data, order: @order, index: @index)
        end

        private

        def process_data
          return skip_data(@data, 1, 1) if @order && @index
          return skip_data(@data, 1, 0) if @order
          return skip_data(@data, 0, 1) if @index
          @data
        end

        def process_index
          return nil unless @index
          @index = @data.transpose.first
          @index = skip_data(@index, 1) if @order
          @index
        end

        def process_order
          return nil unless @order
          @order = @data.first
          @order = skip_data(@order, 1) if @index
          @order
        end

        def skip_data(data, rows, cols=nil)
          return data[rows..-1].map { |row| row[cols..-1] } unless cols.nil?
          data[rows..-1]
        end

        def strip_html_tags(data)
          data.map do |row|
            row.map do |ele|
              next ele unless ele.is_a?(String)
              ele.gsub(/<[^>]+>/, '')
            end
          end
        end
      end
    end
  end
end
