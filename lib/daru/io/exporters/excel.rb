require 'daru/io/exporters/linkages/excel'

module Daru
  module IO
    module Exporters
      class Excel
        # Exports *Daru::DataFrame* to an Excel Spreadsheet.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
        # @param path [String] Path of the file where the *Daru::DataFrame*
        #   should be written.
        # @param options [Hash] A set of options containing user-preferences
        #
        # @example Writing to an Excel file without options
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #=>       a   b
        #   #=>   0   1   3
        #   #=>   1   2   4
        #
        #   Daru::IO::Exporters::Excel.new(df, "dataframe_df.xls").call
        #
        # @todo The +opts+ parameter isn't used while creating the Excel Spreadsheet
        #   yet. Implementing this feature will greatly allow the user to generate a
        #   Spreadsheet of their choice.
        def initialize(dataframe, path, **options)
          @dataframe = dataframe
          @path      = path
          @options   = options
        end

        # @note
        #
        #   The +format+ variable used in this method, has to be given
        #   as options by the user via the +options+ hash input.
        #
        #   Signed off by @athityakumar on 03/06/2017 at 7:00PM
        def call
          book  = Spreadsheet::Workbook.new
          sheet = book.create_worksheet

          format = Spreadsheet::Format.new color: :blue, weight: :bold

          sheet.row(0).concat(@dataframe.vectors.to_a.map(&:to_s)) # Unfreeze strings
          sheet.row(0).default_format = format
          @dataframe.each_row_with_index { |row, i| sheet.row(i+1).concat(row.to_a) }

          book.write(@path)
        end
      end
    end
  end
end
