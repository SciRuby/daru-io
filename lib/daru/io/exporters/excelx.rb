require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      # Excelx Exporter Class, that extends `to_excelx_string` and `write_excelx` methods to
      # `Daru::DataFrame` instance variables
      class Excelx < Base
        Daru::DataFrame.register_io_module :to_excelx_string, self
        Daru::DataFrame.register_io_module :write_excelx, self

        # Initializes an Excelx Exporter instance.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export. Supports even dataframes
        #   with multi-index.
        # @param sheet [String] A sheet name, to export the dataframe into. Defaults to
        #   'Sheet0'.
        # @param header [Boolean] Defaults to true. When set to false or nil,
        #   headers are not written.
        # @param data [Boolean] Defaults to true. When set to false or nil,
        #   data values are not written.
        # @param index [Boolean] Defaults to true. When set to false or nil,
        #   index values are not written
        #
        # @example Initializing an Excel Exporter instance
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      a   b
        #   #  0   1   3
        #   #  1   2   4
        #
        #   instance = Daru::IO::Exporters::Excelx.new(df)
        def initialize(dataframe, sheet: 'Sheet0', header: true, data: true, index: true)
          optional_gem 'rubyXL'

          super(dataframe)
          @data   = data
          @index  = index
          @sheet  = sheet
          @header = header
        end

        # Exports an Excelx Exporter instance to a file-writable String.
        #
        # @return [String] A file-writable string
        #
        # @example Getting a file-writable string from Excelx Exporter instance
        #   instance.to_s
        #
        #   #=> "PK\u0003\u0004\u0014\u0000\u0000\u0000\b\u0000X\xA5YK\u0018\x87\xFC\u0017..."
        def to_s
          super(file_extension: '.xlsx')
        end

        # Exports an Excelx Exporter instance to an xlsx file.
        #
        # @param path [String] Path of excelx file where the dataframe is to be saved
        #
        # @example Writing an Excelx Exporter instance to an xlsx file
        #   instance.write('filename.xlsx')
        def write(path)
          @workbook = RubyXL::Workbook.new
          @sheet    = @workbook.add_worksheet(@sheet)
          process_offsets

          write_row(@header ? 0 : 1, fetch_headers)

          @dataframe.each_row_with_index.with_index do |(row, idx), i|
            write_row(@row_offset+i, fetch_index(idx) + fetch_data(row))
          end

          @workbook.write(path)
          true
        end

        private

        def process_offsets
          @row_offset   = @header ? 1 : 0
          @col_offset   = 0 unless @index
          @col_offset ||= @dataframe.index.is_a?(Daru::MultiIndex) ? @dataframe.index.width : 1
        end

        def fetch_headers
          formatting([' '] * @col_offset + @dataframe.vectors.map(&:to_s), @header)
        end

        def fetch_index(idx)
          formatting(idx, @index)
        end

        def fetch_data(row)
          formatting(row, @data)
        end

        def formatting(idx, format)
          return [] unless format

          case idx
          when Daru::Vector, Daru::MultiIndex, Array then idx.map(&:to_s)
          else [idx.to_s]
          end
        end

        def write_row(row_index, row_array)
          row_array.each_with_index do |element, col_index|
            @sheet.insert_cell(row_index, col_index, element.to_s)
          end
        end
      end
    end
  end
end
