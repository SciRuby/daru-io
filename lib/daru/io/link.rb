module Daru
  class DataFrame
    class << self
      # Links `Daru::DataFrame` Import / Export methods to corresponding
      # `Daru::IO` Importer / Exporter classes. Here is the list of linkages:
      #
      # #### Importers
      #
      # | `Daru::DataFrame` method          | `Daru::IO::Importers` class                  |
      # | ----------------------------------- | -----------------------------------------------|
      # | `Daru::DataFrame.from_activerecord` | {Daru::IO::Importers::ActiveRecord#initialize} |
      # | `Daru::DataFrame.from_avro`         | {Daru::IO::Importers::Avro#initialize}         |
      # | `Daru::DataFrame.from_csv`          | {Daru::IO::Importers::CSV#initialize}          |
      # | `Daru::DataFrame.from_excel`        | {Daru::IO::Importers::Excel#initialize},       |
      # |                                     |  {Daru::IO::Importers::Excelx#initialize}      |
      # | `Daru::DataFrame.from_html`         | {Daru::IO::Importers::HTML#initialize}         |
      # | `Daru::DataFrame.from_json`         | {Daru::IO::Importers::JSON#initialize}         |
      # | `Daru::DataFrame.from_mongo`        | {Daru::IO::Importers::Mongo#initialize}        |
      # | `Daru::DataFrame.from_plaintext`    | {Daru::IO::Importers::Plaintext#initialize}    |
      # | `Daru::DataFrame.from_rdata`        | {Daru::IO::Importers::RData#initialize}        |
      # | `Daru::DataFrame.from_rds`          | {Daru::IO::Importers::RDS#initialize}          |
      # | `Daru::DataFrame.from_redis`        | {Daru::IO::Importers::Redis#initialize}        |
      # | `Daru::DataFrame.from_sql`          | {Daru::IO::Importers::SQL#initialize}          |
      #
      # #### Exporters
      #
      # | `Daru::DataFrame` instance method | `Daru::IO::Exporters` class            |
      # | ----------------------------------- | -----------------------------------------|
      # | `Daru::DataFrame.to_avro`           | {Daru::IO::Exporters::Avro#initialize}   |
      # | `Daru::DataFrame.to_csv`            | {Daru::IO::Exporters::CSV#initialize}    |
      # | `Daru::DataFrame.to_excel`          | {Daru::IO::Exporters::Excel#initialize}  |
      # | `Daru::DataFrame.to_json`           | {Daru::IO::Exporters::JSON#initialize}   |
      # | `Daru::DataFrame.to_rds`            | {Daru::IO::Exporters::RDS#initialize}    |
      # | `Daru::DataFrame.to_sql`            | {Daru::IO::Exporters::SQL#initialize}    |
      #
      # @param function [Symbol] Functon name to be monkey-patched into +Daru::DataFrame+
      # @param instance [Class] The Daru-IO class to be linked to monkey-patched function
      #
      # @return A `Daru::DataFrame` class method in case of Importer, and instance
      #   variable method in case of Exporter.
      def register_io_module(function, instance=nil, &block)
        return define_singleton_method(function, &block) if block_given?

        if function.to_s.include? 'to'
          define_method(function) { |*args, &io_block| instance.new(self, *args, &io_block).call }
        else
          define_singleton_method(function) { |*args| instance.new(*args).call }
        end
      end
    end
  end
end
