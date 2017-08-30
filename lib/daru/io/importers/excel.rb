require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # Excel Importer Class, that extends `read_excel` method to `Daru::DataFrame`
      class Excel < Base
        Daru::DataFrame.register_io_module :read_excel do |*args, &io_block|
          if args.first.end_with?('.xlsx')
            require 'daru/io/importers/excelx'
            Daru::IO::Importers::Excelx.new(*args[1..-1], &io_block).read(*args[0])
          else
            Daru::IO::Importers::Excel.new(*args[1..-1], &io_block).read(*args[0])
          end
        end

        # Initializes an Excel Importer instance
        #
        # @param worksheet_id [Integer] The index of the worksheet in the excel file,
        #   from where the `Daru::DataFrame` will be imported. By default, the first
        #   worksheet has `:worksheet_id` as 0. In general, the n-th worksheet has
        #   its worksheet_id as n-1.
        #
        #   If worksheet_id option is not given, it is taken as 0 by default and the
        #   `Daru::DataFrame` will be imported from the first worksheet in the excel file.
        # @param headers [Boolean] Defaults to true. When set to true, first row of the
        #   given worksheet_id is used as the order of the Daru::DataFrame and data of
        #   the Dataframe consists of the remaining rows.
        #
        # @example Initializing from default worksheet_id
        #   default_instance = Daru::IO::Importers::Excel.new
        #
        # @example Initializing from a specific worksheet
        #   specific_instance = Daru::IO::Importers::Excel.new(worksheet_id: 0)
        def initialize(worksheet_id: 0, headers: true)
          optional_gem 'spreadsheet', '~> 1.1.1'

          @headers      = headers
          @worksheet_id = worksheet_id
        end

        def read(path)
          @file_string = Spreadsheet.open(path)
          self
        end

        # Imports a `Daru::DataFrame` from an Excel Importer instance and xls file
        #
        # @param path [String] Path of Excel file, where the DataFrame is to be imported from.
        #
        # @return [Daru::DataFrame]
        #
        # @example Reading from a default worksheet_id of an Excel file
        #   df = default_instance.read("test_xls.xls")
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
        # @example Reading from a specific worksheet_id of an Excel file
        #   df = specific_instance.read("test_xls.xls")
        #
        #   #=> #<Daru::DataFrame(6x5)>
        #   #            id     name      age     city       a1
        #   #    0        1     Alex       20 New York      a,b
        #   #    1        2   Claude       23   London      b,c
        #   #    2        3    Peter       25   London        a
        #   #    3        4    Franz      nil    Paris      nil
        #   #    4        5   George      5.5     Tome    a,b,c
        #   #    5        6  Fernand      nil      nil      nil
        def call(worksheet_id: 0, headers: true)
          worksheet = @file_string.worksheet(worksheet_id)
          headers   = if headers
                        ArrayHelper.recode_repeated(worksheet.row(0)).map(&:to_sym)
                      else
                        (0..worksheet.row(0).to_a.size-1).to_a
                      end

          df = Daru::DataFrame.new({})
          headers.each_with_index do |h,i|
            col = worksheet.column(i).to_a
            col.delete_at(0) if headers
            df[h] = col
          end

          df
        end
      end
    end
  end
end
