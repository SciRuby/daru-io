require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      # Excel Exporter Class, that extends **to_excel** method to **Daru::DataFrame**
      # instance variables
      class Excel < Base
        Daru::DataFrame.register_io_module :to_excel, self

        # Exports **Daru::DataFrame** to an Excel Spreadsheet.
        #
        # @note For giving formatting options as hashes to the `:data`, `:index` or `header`
        #   keyword argument(s), please have a look at the
        #   {http://www.rubydoc.info/gems/ruby-spreadsheet/Spreadsheet/Font Spreadsheet::Font}
        #   and
        #   {http://www.rubydoc.info/gems/ruby-spreadsheet/Spreadsheet/Format Spreadsheet::Format}
        #   pages.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
        # @param path [String] Path of the file where the **Daru::DataFrame**
        #   should be written.
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
        # @example Writing to an Excel file with formatting options
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      a   b
        #   #  0   1   3
        #   #  1   2   4
        #
        #   Daru::IO::Exporters::Excel.new(df,
        #     "dataframe_df.xls",
        #     header: { color: :red, weight: :bold },
        #     index:  false,
        #     data:   { color: :blue }
        #   ).call
        #
        # @example Writing a DataFrame with Multi-Index to an Excel file
        #   df = Daru::DataFrame.new [[1,2],[3,4]], order: [:x, :y], index: [[:a, :b, :c], [:d, :e, :f]]
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #             x   y
        #   #  a  b   c   1   3
        #   #  d  e   f   2   4
        #
        #   Daru::IO::Exporters::Excel.new(df,
        #     "dataframe_df.xls",
        #     header: { color: :red, weight: :bold },
        #     index:  { color: :green },
        #     data:   { color: :blue }
        #   ).call
        def initialize(dataframe, path, header: true, data: true, index: true)
          optional_gem 'spreadsheet', '~> 1.1.1'

          super(dataframe)
          @path   = path
          @data   = data
          @index  = index
          @header = header
        end

        def call
          @book  = Spreadsheet::Workbook.new
          @sheet = @book.create_worksheet

          process_offsets
          write_headers

          @dataframe.each_row_with_index.with_index do |(row, idx), r|
            write_index(idx, r+@row_offset)
            write_data(row,  r+@row_offset)
          end

          @book.write(@path)
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
