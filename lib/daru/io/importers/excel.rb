require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      class Excel < Base
        Daru::DataFrame.register_io_module :from_excel do |*args|
          if args.first.end_with? '.xlsx'
            require 'daru/io/importers/excelx'
            Daru::IO::Importers::Excelx.new(*args).call
          else
            Daru::IO::Importers::Excel.new(*args).call
          end
        end

        # Imports a +Daru::DataFrame+ from an Excel file (.xls, or .xlsx formats)
        #
        # @param path [String] Path of Excel file, where the
        #   DataFrame is to be imported from.
        # @param sheet [Integer] The index of the worksheet in the excel file,
        #   from where the +Daru::DataFrame+ will be imported. By default, the first
        #   worksheet has +sheet+ as 0. In general, the n-th worksheet has
        #   its sheet as n-1.
        #
        #   If sheet option is not given, it is taken as 0 by default and the
        #   +Daru::DataFrame+ will be imported from the first worksheet in the excel file.
        # @param headers [Boolean] Defaults to true. When set to true, first row of the
        #   given sheet is used as the order of the Daru::DataFrame and data of
        #   the Dataframe consists of the remaining rows.
        #
        # @return A +Daru::DataFrame+ imported from the given excel worksheet
        #
        # @example Reading from a default worksheet of an Excel file
        #   df = Daru::IO::Importers::Excel.new("test_xls.xls").call
        #   df
        #
        #   #=> #<Daru::DataFrame(6x5)>
        #   #            id     name      age     city       a1
        #   #    0        1     Alex       20 New York      a,b
        #   #    1        2   Claude       23   London      b,c
        #   #    2        3    Peter       25   London        a
        #   #    3        4    Franz      nil    Paris      nil
        #   #    4        5   George      5.5     Tome    a,b,c
        #   #    5        6  Fernand      nil      nil      nil
        #
        # @example Reading from a specific worksheet of an Excel file
        #   df = Daru::IO::Importers::Excel.new("test_xls.xls", sheet: 0).call
        #   df
        #
        #   #=> #<Daru::DataFrame(6x5)>
        #   #            id     name      age     city       a1
        #   #    0        1     Alex       20 New York      a,b
        #   #    1        2   Claude       23   London      b,c
        #   #    2        3    Peter       25   London        a
        #   #    3        4    Franz      nil    Paris      nil
        #   #    4        5   George      5.5     Tome    a,b,c
        #   #    5        6  Fernand      nil      nil      nil
        def initialize(path, sheet: 0, headers: true)
          optional_gem 'spreadsheet', '~> 1.1.1'

          @path    = path
          @sheet   = sheet
          @headers = headers
        end

        def call
          worksheet = Spreadsheet.open(@path).worksheet(@sheet)
          headers   = if @headers
                        ArrayHelper.recode_repeated(worksheet.row(0)).map(&:to_sym)
                      else
                        (0..worksheet.row(0).to_a.size-1).to_a
                      end

          df = Daru::DataFrame.new({})
          headers.each_with_index do |h,i|
            col = worksheet.column(i).to_a
            col.delete_at(0) if @headers
            df[h] = col
          end

          df
        end
      end
    end
  end
end
