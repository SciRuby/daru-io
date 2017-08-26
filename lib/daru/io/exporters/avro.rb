require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      # Avro Exporter Class, that extends `to_avro` method to `Daru::DataFrame`
      # instance variables
      class Avro < Base
        Daru::DataFrame.register_io_module :to_avro_string, self
        Daru::DataFrame.register_io_module :write_avro, self

        # Exports `Daru::DataFrame` to an Avro file.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
        # @param path [String] Path of Avro file where the dataframe is to be saved
        # @param schema [Avro::Schema or Hash] The schema should contain details such as `:type`,
        #   `:name` and `:fields`
        #
        # @example Writing to an Avro file
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
        #   Daru::IO::Exporters::Avro.new(df, schema).write("azorahai.avro")
        def initialize(dataframe, schema=nil)
          optional_gem 'avro'
          require 'json'

          super(dataframe)
          @schema = schema
        end

        def write(path)
          @schema_obj = process_schema
          @writer     = ::Avro::IO::DatumWriter.new(@schema_obj)
          @buffer     = StringIO.new
          @writer     = ::Avro::DataFile::Writer.new(@buffer, @writer, @schema_obj)
          @dataframe.each_row { |row| @writer << row.to_h }
          @writer.close

          File.open(path, 'w') { |file| file.write(@buffer.string) }
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
