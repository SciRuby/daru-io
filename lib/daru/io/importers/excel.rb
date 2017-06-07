require 'daru/io/importers/linkages/excel'

module Daru
  module IO
    module Importers
      class Excel
        def initialize(path, worksheet_id: 0)
          @path = path
          @worksheet_id = worksheet_id
        end

        def load
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
