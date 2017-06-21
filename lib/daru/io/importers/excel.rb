require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      class Excel < Base
        # Imports a +Daru::DataFrame+ from an Excel file.
        #
        # @param path [String] Path of Excel file, where the
        #   DataFrame is to be imported from.
        # @param worksheet_id [Interger] The index of the worksheet in the excel file,
        #   from where the +Daru::DataFrame+ will be imported. By default, the first
        #   worksheet has +worksheet_id+ as 0. In general, the n-th worksheet has
        #   its worksheet_id as n-1.
        #
        #   If worksheet_id option is not given, it is taken as 0 by default and the
        #   +Daru::DataFrame+ will be imported from the first worksheet in the excel file.
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
        #   df = Daru::IO::Importers::Excel.new("test_xls.xls", worksheet_id: 0).call
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
        def initialize(path, worksheet_id: 0)
          @path         = path
          @worksheet_id = worksheet_id
        end

        def call
          optional_gem 'spreadsheet', '~> 1.1.1'

          book       = Spreadsheet.open @path
          worksheet  = book.worksheet @worksheet_id
          headers    = ArrayHelper.recode_repeated(worksheet.row(0)).map(&:to_sym)

          df = Daru::DataFrame.new({})
          headers.each_with_index do |h,i|
            col = worksheet.column(i).to_a
            col.delete_at 0
            df[h] = col
          end

          df
        end
      end
    end
  end
end

require 'daru/io/link'
Daru::DataFrame.register_io_module :from_excel, Daru::IO::Importers::Excel
