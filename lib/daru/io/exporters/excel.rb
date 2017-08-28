require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      # Excel Exporter Class, that extends `to_excel_string` and `write_excel` methods to
      # `Daru::DataFrame` instance variables
      class Excel < Base
        Daru::DataFrame.register_io_module :to_excel_string, self
        Daru::DataFrame.register_io_module :write_excel, self

        # Initializes an Excel Exporter instance.
        #
        # @note For giving formatting options as hashes to the `:data`, `:index` or `header`
        #   keyword argument(s), please have a look at the
        #   {http://www.rubydoc.info/gems/ruby-spreadsheet/Spreadsheet/Font Spreadsheet::Font}
        #   and
        #   {http://www.rubydoc.info/gems/ruby-spreadsheet/Spreadsheet/Format Spreadsheet::Format}
        #   pages.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export. Supports even dataframes
        #   with multi-index.
        # @param header [Hash or Boolean] Defaults to true. When set to false or nil,
        #   headers are not written. When given a hash of formatting options,
        #   headers are written with the specific formatting. When set to true,
        #   headers are written without any formatting.
        # @param data [Hash or Boolean] Defaults to true. When set to false or nil,
        #   data values are not written. When given a hash of formatting options,
        #   data values are written with the specific formatting. When set to true,
        #   data values are written without any formatting.
        # @param index [Hash or Boolean] Defaults to true. When set to false or nil,
        #   index values are not written. When given a hash of formatting options,
        #   index values are written with the specific formatting. When set to true,
        #   index values are written without any formatting.
        #
        # @example Initializing an Excel Exporter instance
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      a   b
        #   #  0   1   3
        #   #  1   2   4
        #
        #   simple_instance = Daru::IO::Exporters::Excel.new(df)
        #   formatted_instance = Daru::IO::Exporters::Excel.new(
        #     df,
        #     header: { color: :red, weight: :bold },
        #     index: false,
        #     data: { color: :blue }
        #   )
        def initialize(dataframe, header: true, data: true, index: true)
          optional_gem 'spreadsheet', '~> 1.1.1'

          super(dataframe)
          @data   = data
          @index  = index
          @header = header
        end

        # Exports an Excel Exporter instance to a file-writable String.
        #
        # @return [String] A file-writable string
        #
        # @example Getting a file-writable string from Excel Exporter instance
        #   simple_instance.to_s #! same as df.to_avro_string(schema)
        #
        #   #=> "\xD0\xCF\u0011\u0871\u001A\xE1\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000..."
        #
        #   formatted_instance.to_s
        #
        #   #=> "\xD0\xCF\u0011\u0871\u001A\xE1\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000..."
        def to_s
          super
        end

        # Exports an Excel Exporter instance to an xls file.
        #
        # @param path [String] Path of excel file where the dataframe is to be saved
        #
        # @example Writing an Excel Exporter instance to an xls file
        #   instance.write('filename.xls')
        def write(path)
          @book  = Spreadsheet::Workbook.new
          @sheet = @book.create_worksheet

          process_offsets
          write_headers

          @dataframe.each_row_with_index.with_index do |(row, idx), r|
            write_index(idx, r+@row_offset)
            write_data(row,  r+@row_offset)
          end

          @book.write(path)
        end

        private

        def process_offsets
          @row_offset   = @header ? 1 : 0
          @col_offset   = 0 unless @index
          @col_offset ||= @dataframe.index.is_a?(Daru::MultiIndex) ? @dataframe.index.width : 1
        end

        def write_headers
          formatting(
            0...@col_offset + @dataframe.ncols,
            0,
            [' '] * @col_offset + @dataframe.vectors.map(&:to_s),
            @header
          )
        end

        def write_index(idx, row)
          formatting(
            0...@col_offset,
            row,
            idx,
            @index
          )
        end

        def write_data(row, idx)
          formatting(
            @col_offset...@col_offset + @dataframe.ncols,
            idx,
            row,
            @data
          )
        end

        def formatting(col_range, row, idx, format)
          return unless format
          @sheet.row(row).concat(
            case idx
            when Daru::Vector then idx.to_a
            when Array then idx.map(&:to_s)
            else [idx.to_s]
            end
          )

          return unless format.is_a?(Hash)
          col_range.each { |col| @sheet.row(row).set_format(col, Spreadsheet::Format.new(format)) }
        end
      end
    end
  end
end
