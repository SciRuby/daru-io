require 'daru/io/exporters/linkages/excel'

module Daru
  module IO
    module Exporters
      module Excel
        class << self
          def write(dataframe, path, opts={})
            book = ExcelHelper.prepare dataframe, opts
            book.write(path)
          end
        end
      end
      module ExcelHelper
        class << self
          def prepare(dataframe, _opts={})
            book   = Spreadsheet::Workbook.new
            sheet  = book.create_worksheet
            format = Spreadsheet::Format.new color: :blue, weight: :bold

            sheet.row(0).concat(dataframe.vectors.to_a.map(&:to_s)) # Unfreeze strings
            sheet.row(0).default_format = format
            i = 1
            dataframe.each_row do |row|
              sheet.row(i).concat(row.to_a)
              i += 1
            end
            book
          end
        end
      end
    end
  end
end
