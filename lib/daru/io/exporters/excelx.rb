require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      # Excelx Exporter Class, that extends `to_excelx_string` and `write_excelx` methods to
      # `Daru::DataFrame` instance variables
      class Excelx < Base
        Daru::DataFrame.register_io_module :to_excelx_string, self
        Daru::DataFrame.register_io_module :write_excelx, self

        # Initializes an Excel Exporter instance.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export. Supports even dataframes
        #   with multi-index.
        # @param sheet [String] A sheet name, to export the dataframe into.
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
        def initialize(dataframe, sheet: '0', header: true, data: true, index: true)
          optional_gem 'axlsx'

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
        # @example Getting a file-writable string from Excel Exporter instance
        #   simple_instance.to_s #! same as df.to_avro_string(schema)
        #
        #   #=> "\xD0\xCF\u0011\u0871\u001A\xE1\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000..."
        def to_s
          super
        end

        # Exports an Excelx Exporter instance to an xlsx file.
        #
        # @param path [String] Path of excelx file where the dataframe is to be saved
        #
        # @example Writing an Excel Exporterx instance to an xlsx file
        #   instance.write('filename.xlsx')
        def write(path)
          @package = Axlsx::Package.new
          @workbook = @package.workbook

          process_offsets

          @workbook.add_worksheet(:name => @sheet) do |sheet|
            sheet.add_row(fetch_headers)

            @dataframe.each_row_with_index do |row, idx|
              sheet.add_row(fetch_index(idx) + fetch_data(row))
            end
          end

          @package.serialize(path)
        end

        private

        def process_offsets
          @row_offset   = @header ? 1 : 0
          @col_offset   = 0 unless @index
          @col_offset ||= @dataframe.index.is_a?(Daru::MultiIndex) ? @dataframe.index.width : 1
        end

        def fetch_headers
          fetching([' '] * @col_offset + @dataframe.vectors.map(&:to_s), @header)
        end

        def fetch_index(idx)
          fetching(idx, @index)
        end

        def fetch_data(row)
          fetching(row, @data)
        end

        def fetching(idx, format)
          return [] unless format

          case idx
          when Daru::Vector then idx.to_a
          when Array then idx.map(&:to_s)
          else [idx.to_s]
          end
        end
      end
    end
  end
end