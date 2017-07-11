require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      class Excel < Base
        Daru::DataFrame.register_io_module :to_excel, self

        # Exports +Daru::DataFrame+ to an Excel Spreadsheet.
        #
        # @note To know more about the +Spreadsheet+ parameter hashes that can be given as
        #   +data_options+ and +header_options+ parameters, please have a look at the methods
        #   described in
        #   {http://www.rubydoc.info/gems/ruby-spreadsheet/Spreadsheet/Font Spreadsheet::Font}
        #   and
        #   {http://www.rubydoc.info/gems/ruby-spreadsheet/Spreadsheet/Format Spreadsheet::Format}
        #   pages.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
        # @param path [String] Path of the file where the +Daru::DataFrame+
        #   should be written.
        # @param data_options [Hash] A set of +Spreadsheet+ options containing user-preferences
        #   about the +Daru::DataFrame+ data being written.
        # @param header_options [Hash] A set of +Spreadseet+ options containing user-preferences
        #   about the +Daru::DataFrame+ headers being written.
        #
        # @example Writing to an Excel file without options
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      a   b
        #   #  0   1   3
        #   #  1   2   4
        #
        #   Daru::IO::Exporters::Excel.new(df, "dataframe_df.xls").call
        #
        # @example Writing to an Excel file with options
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      a   b
        #   #  0   1   3
        #   #  1   2   4
        #
        #   normal  = { color: :blue }
        #   heading = { color: :red, weight: :bold }
        #
        #   Daru::IO::Exporters::Excel.new(df,
        #     "dataframe_df.xls",
        #     data_options: normal,
        #     header_options: heading
        #   ).call
        def initialize(dataframe, path, header_options: {}, data_options: {})
          optional_gem 'spreadsheet', '~> 1.1.1'

          super(dataframe)
          @path           = path
          @data_options   = data_options
          @header_options = header_options
        end

        def call
          book  = Spreadsheet::Workbook.new
          sheet = book.create_worksheet

          sheet.row(0).concat(@dataframe.vectors.to_a.map(&:to_s))
          sheet.row(0).default_format = Spreadsheet::Format.new(@header_options)

          @dataframe.each_row_with_index do |row, i|
            sheet.row(i+1).concat(row.to_a)
            sheet.row(i+1).default_format = Spreadsheet::Format.new(@data_options)
          end

          book.write(@path)
        end
      end
    end
  end
end
