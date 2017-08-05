require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      class Avro < Base
        Daru::DataFrame.register_io_module :to_avro, self

        # Exports a +Daru::DataFrame+ from a CSV file.
        #
        # @param path [String] Local / Remote path of CSV file, where the
        #   dataframe is to be imported from.
        # @param headers [Boolean] If this option is +true+, only those columns
        #   will be used to import the +Daru::DataFrame+ whose header is given.
        # @param col_sep [String] A column separator, to be used while
        #   importing from the CSV file. By default, it is set to ','
        # @param converters [Symbol] If set to +:numeric+, each value in
        #   the imported +Daru::DataFrame+ will be numeric and not string.
        # @param header_converters [Symbol] If set to +:symbol+, the order of
        #   the imported +Daru::DataFrame+ will be symbol (eg, +:name+) instead
        #   of being a string.
        # @param clone [Boolean] Have a look at +:clone+ option, at
        #   {http://www.rubydoc.info/gems/daru/0.1.5/Daru%2FDataFrame:initialize
        #   Daru::DataFrame#initialize}
        # @param index [Array or Daru::Index or Daru::MultiIndex] Have a look at
        #   +:index+ option, at
        #   {http://www.rubydoc.info/gems/daru/0.1.5/Daru%2FDataFrame:initialize
        #   Daru::DataFrame#initialize}
        # @param order [Array or Daru::Index or Daru::MultiIndex] Have a look at
        #   +:order+ option, at
        #   {http://www.rubydoc.info/gems/daru/0.1.5/Daru%2FDataFrame:initialize
        #   Daru::DataFrame#initialize}
        # @param name [String] Have a look at +:name+ option, at
        #   {http://www.rubydoc.info/gems/daru/0.1.5/Daru%2FDataFrame:initialize
        #   Daru::DataFrame#initialize}
        # @param options [Hash] CSV standard library options, to tweak other
        #   default options of CSV gem.
        #
        # @return A +Daru::DataFrame+ imported from the given relation and fields
        #
        # @example Reading from a CSV file from columns whose header is given
        #   df = Daru::DataFrame.from_csv("matrix_test.csv", col_sep: ' ', headers: true)
        #
        #   #=> #<Daru::DataFrame(99x3)>
        #   #        image_reso        mls true_trans
        #   #      0    6.55779          0 -0.2362347
        #   #      1    2.14746          0 -0.1539447
        #   #      2    8.31104          0 0.3832846,
        #   #      3    3.47872          0 0.3832846,
        #   #      4    4.16725          0 -0.2362347
        #   #      5    5.79983          0 -0.2362347
        #   #      6     1.9058          0 -0.895577,
        #   #      7     1.9058          0 -0.2362347
        #   #      8    4.11806          0 -0.895577,
        #   #      9    6.26622          0 -0.2362347
        #   #     10    2.57805          0 -0.1539447
        #   #     11    4.76151          0 -0.2362347
        #   #     12    7.11002          0 -0.895577,
        #   #     13    5.40811          0 -0.2362347
        #   #     14    8.19567          0 -0.1539447
        #   #    ...        ...        ...        ...
        def initialize(dataframe, path, schema=nil)
          optional_gem 'avro'

          super(dataframe)
          @path   = path
          @schema = process_schema(schema)
        end

        def call
          @schema     = process_schema
          @schema_obj = ::Avro::Schema.parse(@schema)
          @writer     = ::Avro::IO::DatumWriter.new(@schema_obj)
          @buffer     = StringIO.new
          @writer     = ::Avro::DataFile::Writer.new(@buffer, @writer, @schema_obj)
          @dataframe.each_row { |row| @writer << row.to_h }
          @writer.close

          File.open(@path, 'w') { |file| file.write(@buffer.string) }
        end

        private

        def process_schema(schema)
          case schema
          when String then schema
          when Hash   then schema.to_json
          else raise ArgumentError, 'Invalid Avro Schema provided.'
          end
        end
      end
    end
  end
end
