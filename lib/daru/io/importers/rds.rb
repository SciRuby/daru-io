require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # RDS Importer Class, that extends `read_rds` method to `Daru::DataFrame`
      class RDS < Base
        Daru::DataFrame.register_io_module :read_rds, self

        # Initializes a RDS Importer instance
        #
        # @example Initializing without options
        #   instance = Daru::IO::Importers::RDS.new
        def initialize
          optional_gem 'rsruby'
        end

        # Imports a `Daru::DataFrame` from a RDS Importer instance and rds file
        #
        # @param path [String] Path to RDS file, where the dataframe is to be imported from.
        #
        # @return [Daru::DataFrame]
        #
        # @example Reading from a RDS file
        #   df = instance.read('bc_sites.rds')
        #
        #   #=> #<Daru::DataFrame(1113x25)>
        #   #         area descriptio  epa_reach format_ver   latitude   location location_c ...
        #   #  0      016  GSPTN             NaN        4.1       49.5    THOR IS 2MS22016 T ...
        #   #  1      012  CSPT              NaN        4.1    50.6167    MITC BY 2MN26012 M ...
        #   # ...     ...  ...               ...        ...       ...       ...       ...    ...
        def read(path)
          process_dataframe(RSRuby.instance.eval_R("readRDS('#{path}')"))
        end

        private

        def process_dataframe(data)
          data = data.map { |key, values| [key.to_sym, values.map { |val| convert_datatype(val) }] }.to_h
          Daru::DataFrame.new(data)
        end

        def convert_datatype(value)
          case value.to_s
          when 'NaN'           then nil
          when value.to_f.to_s then value.to_f
          when value.to_i.to_s then value.to_i
          else value
          end
        end
      end
    end
  end
end
