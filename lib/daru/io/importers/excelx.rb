require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # Excelx Importer Class, that handles .xlsx files in the Excel Importer
      #
      # @see Daru::IO::Importers::Excel For .xls format
      class Excelx < Base
        # Checks for required gem dependencies of Excelx Importer
        def initialize
          optional_gem 'roo', '~> 2.7.0'
        end

        # Reads from an excelx (xlsx) file
        #
        # @!method self.read(path)
        #
        # @param path [String] Local / Remote path of xlsx file, where the DataFrame is
        #   to be imported from.
        #
        # @return [Daru::IO::Importers::Excelx]
        #
        # @example Reading from a local xlsx file
        #   local_instance = Daru::IO::Importers::Excelx.read("Stock-counts-sheet.xlsx")
        #
        # @example Reading from a remote xlsx file
        #   url = "https://www.exact.com/uk/images/downloads/getting-started-excel-sheets/Stock-counts-sheet.xlsx"
        #   remote_instance = Daru::IO::Importers::Excelx.read(url)
        def read(path)
          @file_data = Roo::Excelx.new(path)
          self
        end

        # Imports a `Daru::DataFrame` from an Excelx Importer instance
        #
        # @param sheet [Integer or String] Imports from a specific sheet
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
        # @return [Daru::DataFrame]
        #
        # @example Importing from specific sheet
        #   df = local_instance.call(sheet: 'Example Stock Counts')
        #
        #   #=> <Daru::DataFrame(15x7)>
        #   #           Status Stock coun  Item code        New Descriptio Stock coun Offset G/L
        #   #     0          H          1        nil        nil New stock  2014-08-01        nil
        #   #     1        nil          1  IND300654          2 New stock  2014-08-01      51035
        #   #     2        nil          1   IND43201          5 New stock  2014-08-01      51035
        #   #     3        nil          1   OUT30045          3 New stock  2014-08-01      51035
        #   #    ...       ...        ...     ...           ...     ...       ...           ...
        #
        # @example Importing from a remote URL and default sheet
        #   df = remote_instance.call
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
        #   df = local_instance.call(sheet: 'Example Stock Counts', headers: false)
        #
        #   #=> <Daru::DataFrame(16x7)>
        #   #                0           1          2          3          4          5        6
        #   #     0      Status Stock coun  Item code        New Descriptio Stock coun Offset G/L
        #   #     1          H          1        nil        nil New stock  2014-08-01        nil
        #   #     2        nil          1  IND300654          2 New stock  2014-08-01      51035
        #   #     3        nil          1   IND43201          5 New stock  2014-08-01      51035
        #   #     4        nil          1   OUT30045          3 New stock  2014-08-01      51035
        #   #    ...       ...        ...     ...           ...     ...       ...           ...
        def call(sheet: 0, skiprows: 0, skipcols: 0, order: true, index: false)
          @order    = order
          @index    = index
          worksheet = @file_data.sheet(sheet)
          @data     = strip_html_tags(skip_data(worksheet.to_a, skiprows, skipcols))
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
