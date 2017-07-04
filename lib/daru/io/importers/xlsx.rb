require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      class XLSX < Base
        Daru::DataFrame.register_io_module :from_xlsx, self

        # Imports a +Daru::DataFrame+ from a given XLSX file and sheet.
        #
        # @param path [String] Local / Remote path to XLSX file
        # @param sheet [String] Sheet name in the given XLSX file. Defaults to 0,
        #   to parse the dataframe from the first sheet.
        # @param headers [Boolean] Defaults to true. When set to true, first row of the
        #   given sheet is used as the order of the Daru::DataFrame and data of
        #   the Dataframe consists of the remaining rows.
        #
        #   When set to false, a default order (0 to n-1) is chosen for the DataFrame,
        #   and the data of the DataFrame consists of all rows in the sheet.
        #
        # @return A +Daru::DataFrame+ imported from the given XLSX file and sheet
        #
        # @example Importing from a local file
        #   path  = 'spec/fixtures/excelx/Stock-counts-sheet.xlsx'
        #   sheet = 'Example Stock Counts'
        #   df    = Daru::IO::Importers::XLSX.new(path, sheet: sheet).call
        #   df
        #
        #   #=> <Daru::DataFrame(15x7)>
        #              Status Stock coun  Item code        New Descriptio Stock coun Offset G/L
        #        0          H          1        nil        nil New stock  2014-08-01        nil
        #        1        nil          1  IND300654          2 New stock  2014-08-01      51035
        #        2        nil          1   IND43201          5 New stock  2014-08-01      51035
        #        3        nil          1   OUT30045          3 New stock  2014-08-01      51035
        #       ...       ...        ...     ...           ...     ...       ...           ...
        #
        # @example Importing from a local file without headers
        #   path  = 'spec/fixtures/excelx/Stock-counts-sheet.xlsx'
        #   sheet = 'Example Stock Counts'
        #   df    = Daru::IO::Importers::XLSX.new(path, sheet: sheet, headers: false).call
        #   df
        #
        #   #=> <Daru::DataFrame(16x7)>
        #                   0           1          2          3          4          5        6
        #        0      Status Stock coun  Item code        New Descriptio Stock coun Offset G/L
        #        1          H          1        nil        nil New stock  2014-08-01        nil
        #        2        nil          1  IND300654          2 New stock  2014-08-01      51035
        #        3        nil          1   IND43201          5 New stock  2014-08-01      51035
        #        4        nil          1   OUT30045          3 New stock  2014-08-01      51035
        #       ...       ...        ...     ...           ...     ...       ...           ...
        #
        # @example Importing from a remote URL
        #   path = 'https://www.exact.com/uk/images/downloads/getting-started-excel-sheets/Stock-counts-sheet.xlsx'
        #   sheet = 'Example Stock Counts'
        #   df    = Daru::IO::Importers::XLSX.new(path, sheet: sheet).call
        #   df
        #
        #   #=> <Daru::DataFrame(15x7)>
        #              Status Stock coun  Item code        New Descriptio Stock coun Offset G/L
        #        0          H          1        nil        nil New stock  2014-08-01        nil
        #        1        nil          1  IND300654          2 New stock  2014-08-01      51035
        #        2        nil          1   IND43201          5 New stock  2014-08-01      51035
        #        3        nil          1   OUT30045          3 New stock  2014-08-01      51035
        #       ...       ...        ...     ...           ...     ...       ...           ...
        def initialize(path, sheet: 0, headers: true)
          optional_gem 'roo', '~> 2.7.0'

          @path    = path
          @sheet   = sheet
          @headers = headers
        end

        def call
          book      = Roo::Excelx.new(@path)
          worksheet = book.sheet(@sheet)
          data      = worksheet.to_a
          data      = strip_html_tags(data)
          order     = @headers ? data.delete_at(0) : (0..data.first.length-1).to_a

          Daru::DataFrame.rows(data, order: order)
        end

        private

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
