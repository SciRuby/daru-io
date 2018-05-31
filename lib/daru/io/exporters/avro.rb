require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      # Avro Exporter Class, that extends `to_avro_string` and `write_avro` methods to
      # `Daru::DataFrame` instance variables
      class Avro < Base
        Daru::DataFrame.register_io_module :to_avro_string, self
        Daru::DataFrame.register_io_module :write_avro, self

        # Initializes an Avro Exporter instance.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
        # @param schema [Avro::Schema or Hash] The schema should contain details such as `:type`,
        #   `:name` and `:fields`
        #
        # @return A `Daru::IO::Exporter::Avro` instance
        #
        # @example Initializing an Avro Exporter
        #   schema = {
        #     "type" => "record",
        #     "name" => "User",
        #     "fields" => [
        #       {"name" => "name", "type" => "string"},
        #       {"name" => "points", "type" => "int"},
        #       {"name"=> "winner", "type"=> "boolean", "default"=> "false"}
        #     ]
        #   }
        #
        #   df = Daru::DataFrame.new(
        #     [
        #       {"name"=> "Dany", "points"=> 100, "winner"=> true},
        #       {"name"=> "Jon", "points"=> 100, "winner"=> true},
        #       {"name"=> "Tyrion", "points"=> 100, "winner"=> true}
        #     ]
        #   )
        #
        #   #=> #<Daru::DataFrame(3x3)>
        #   #        name points winner
        #   #    0   Dany    100   true
        #   #    1    Jon    100   true
        #   #    2 Tyrion    100   true
        #
        #   instance = Daru::IO::Exporters::Avro.new(df, schema)
        def initialize(dataframe, schema=nil)
          optional_gem 'avro'
          require 'json'

          super(dataframe)
          @schema = schema
        end

        # Exports an Avro Exporter instance to a file-writable String.
        #
        # @return [String] A file-writable string
        #
        # @example Getting a file-writable string from Avro Exporter instance
        #   instance.to_s
        #
        #   #=> "Obj\u0001\u0004\u0014avro.codec\bnull\u0016avro.schema\xBC\u0002{\"type\":\"record\"..."
        def to_s
          super
        end

        # Exports an Avro Exporter instance to an avro file.
        #
        # @param path [String] Path of Avro file where the dataframe is to be saved
        #
        # @example Writing an Avro Exporter instance to an Avro file
        #   instance.write('azor_ahai.avro')
        def write(path)
          @schema_obj = process_schema
          @writer     = ::Avro::IO::DatumWriter.new(@schema_obj)
          @buffer     = StringIO.new
          @writer     = ::Avro::DataFile::Writer.new(@buffer, @writer, @schema_obj)
          @dataframe.each_row { |row| @writer << row.to_h }
          @writer.close

          File.open(path, 'w') { |file| file.write(@buffer.string) }
          true
        end

        private

        def process_schema
          case @schema
          when ::Avro::Schema then @schema
          when String         then ::Avro::Schema.parse(@schema)
          when Hash           then ::Avro::Schema.parse(@schema.to_json)
          else raise ArgumentError, 'Invalid Avro Schema provided.'
          end
        end
      end
    end
  end
end
