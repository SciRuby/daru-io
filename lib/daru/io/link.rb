module Daru
  class DataFrame
    class << self
      # Links `Daru::DataFrame` Import / Export methods to corresponding
      # `Daru::IO` Importer / Exporter classes. Here is the list of linkages:
      #
      # #### Importers
      #
      # | `Daru::DataFrame` method            | `Daru::IO::Importers` class              |
      # | ----------------------------------- | -----------------------------------------|
      # | `Daru::DataFrame.from_activerecord` | {Daru::IO::Importers::ActiveRecord#from} |
      # | `Daru::DataFrame.read_avro`         | {Daru::IO::Importers::Avro#read}         |
      # | `Daru::DataFrame.read_csv`          | {Daru::IO::Importers::CSV#read}          |
      # | `Daru::DataFrame.read_excel`        | {Daru::IO::Importers::Excel#read},       |
      # |                                     |  {Daru::IO::Importers::Excelx#read}      |
      # | `Daru::DataFrame.read_html`         | {Daru::IO::Importers::HTML#read}         |
      # | `Daru::DataFrame.from_json`         | {Daru::IO::Importers::JSON#from}         |
      # | `Daru::DataFrame.read_json`         | {Daru::IO::Importers::JSON#read}         |
      # | `Daru::DataFrame.from_mongo`        | {Daru::IO::Importers::Mongo#from}        |
      # | `Daru::DataFrame.read_plaintext`    | {Daru::IO::Importers::Plaintext#read}    |
      # | `Daru::DataFrame.read_rdata`        | {Daru::IO::Importers::RData#read}        |
      # | `Daru::DataFrame.read_rds`          | {Daru::IO::Importers::RDS#read}          |
      # | `Daru::DataFrame.from_redis`        | {Daru::IO::Importers::Redis#from}        |
      # | `Daru::DataFrame.from_sql`          | {Daru::IO::Importers::SQL#from}          |
      #
      # #### Exporters
      #
      # | `Daru::DataFrame` instance method | `Daru::IO::Exporters` class        |
      # | --------------------------------- | -----------------------------------|
      # | `Daru::DataFrame.to_avro_string`  | {Daru::IO::Exporters::Avro#to_s}   |
      # | `Daru::DataFrame.write_avro`      | {Daru::IO::Exporters::Avro#write}  |
      # | `Daru::DataFrame.to_csv_string`   | {Daru::IO::Exporters::CSV#to_s}    |
      # | `Daru::DataFrame.write_csv`       | {Daru::IO::Exporters::CSV#write}   |
      # | `Daru::DataFrame.to_excel_string` | {Daru::IO::Exporters::Excel#to_s}  |
      # | `Daru::DataFrame.write_excel`     | {Daru::IO::Exporters::Excel#write} |
      # | `Daru::DataFrame.to_json`         | {Daru::IO::Exporters::JSON#to}     |
      # | `Daru::DataFrame.to_json_string`  | {Daru::IO::Exporters::JSON#to_s}   |
      # | `Daru::DataFrame.write_json`      | {Daru::IO::Exporters::JSON#write}  |
      # | `Daru::DataFrame.to_rds_string`   | {Daru::IO::Exporters::RDS#to_s}    |
      # | `Daru::DataFrame.write_rds`       | {Daru::IO::Exporters::RDS#write}   |
      # | `Daru::DataFrame.to_sql`          | {Daru::IO::Exporters::SQL#to}      |
      #
      # @param function [Symbol] Functon name to be monkey-patched into +Daru::DataFrame+
      # @param instance [Class] The Daru-IO class to be linked to monkey-patched function
      #
      # @return A `Daru::DataFrame` class method in case of Importer, and instance
      #   variable method in case of Exporter.
      def register_io_module(function, instance=nil, &block)
        return define_singleton_method(function, &block) if block_given?

        case function.to_s
        when /\Ato_.*_string\Z/, /\Ato_/, /\Awrite_/ then register_exporter(function, instance)
        when /\Afrom_/, /\Aread_/                    then register_importer(function, instance)
        else raise ArgumentError, 'Invalid function name given to monkey-patch into Daru::DataFrame.'
        end
      end

      private

      def register_exporter(function, instance)
        define_method(function) do |*args, &io_block|
          case function.to_s
          when /\Ato_.*_string\Z/ then instance.new(self, *args, &io_block).to_s
          when /\Ato_/            then instance.new(self, *args, &io_block).to
          when /Awrite_/          then instance.new(self, *args[1..-1], &io_block).write(*args[0])
          end
        end
      end

      def register_importer(function, instance)
        define_singleton_method(function) do |*args, &io_block|
          case function.to_s
          when /\Afrom_/ then instance.new.from(*args[0]).call(*args[1..-1], &io_block)
          when /\Aread_/ then instance.new.read(*args[0]).call(*args[1..-1], &io_block)
          end
        end
      end
    end
  end
end
