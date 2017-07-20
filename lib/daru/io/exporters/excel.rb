require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      class Excel < Base
        Daru::DataFrame.register_io_module :to_excel, self

        # Exports +Daru::DataFrame+ to an Excel Spreadsheet.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
        # @param path [String] Path of the file where the +Daru::DataFrame+
        #   should be written.
        # @param options [Hash<Hash>] A +Hash+ containing +:display+ and +:formatting+ keys.
        #
        # @option options display [Hash<Boolean>] A Hash of display options. Supported keys are
        #   +:header+, +:data+ and +:index+. Default value of each key is set to +true+. For
        #   example, if +:header+ is set to true, the headers are written.
        #
        # @option options formatting [Hash<Hash>] A Hash of formatting options. Supported keys
        #   are +:header+, +:data+ and +:index+. For example, if +:header+ is set to a Hash
        #   containing keys such as +:color+, the headers are written with the specified color.
        #
        #   To know more about the +Spreadsheet+ parameter hashes that can be given as
        #   values to the +:header+, +:data+ or +:index+ keys, please have a look at the
        #   methods described in
        #   {http://www.rubydoc.info/gems/ruby-spreadsheet/Spreadsheet/Font Spreadsheet::Font}
        #   and
        #   {http://www.rubydoc.info/gems/ruby-spreadsheet/Spreadsheet/Format Spreadsheet::Format}
        #   pages.
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
        #   Daru::IO::Exporters::Excel.new(df,
        #     "dataframe_df.xls",
        #     formatting: {
        #       header: { color: :red, weight: :bold },
        #       index:  { color: :green },
        #       data:   { color: :blue }
        #     },
        #     display: { index: false }
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
        #     formatting: {
        #       header: { color: :red, weight: :bold },
        #       index:  { color: :green },
        #       data:   { color: :blue }
        #     }
        #   ).call
        def initialize(dataframe, path, **options)
          optional_gem 'spreadsheet', '~> 1.1.1'

          super(dataframe)
          @path       = path
          @display    = options[:display]    || {}
          @formatting = options[:formatting] || {}

          @display    = {header: true, data: true, index: true}.merge(@display)
        end

        def call
          @book       = Spreadsheet::Workbook.new
          @sheet      = @book.create_worksheet
          @row_offset = @display[:header] ? 1 : 0
          @col_offset = process_col_offset

          write_headers if @display[:header]

          if @display[:index] || @display[:data]
            @dataframe.each_row_with_index.with_index do |row_idx, i|
              row, idx = row_idx

              write_index(idx, i+@row_offset) if @display[:index]
              write_data(row,  i+@row_offset) if @display[:data]
            end
          end

          @book.write(@path)
        end

        private

        def process_col_offset
          return 0 unless @display[:index]
          return 1 unless @dataframe.index.first.is_a?(Array)
          @dataframe.index.first.count
        end

        def write_headers
          @sheet.row(0).default_format = Spreadsheet::Format.new(@formatting[:header] || {})
          @sheet.row(0).concat([' '] * @col_offset + @dataframe.vectors.to_a.map(&:to_s))
        end

        def write_index(idx, i)
          @col_offset.times do |x|
            @sheet.row(i).set_format(x, Spreadsheet::Format.new(@formatting[:index] || {}))
          end
          @sheet.row(i).concat(idx.is_a?(Array) ? idx.to_a.map(&:to_s) : [idx.to_s])
        end

        def write_data(row, i)
          (@col_offset..(@col_offset + @dataframe.vectors.to_a.size-1)).each do |x|
            @sheet.row(i).set_format(x, Spreadsheet::Format.new(@formatting[:data] || {}))
          end
          @sheet.row(i).concat(row.to_a)
        end
      end
    end
  end
end
