require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # RDS Importer Class, that extends `read_rds` method to `Daru::DataFrame`
      #
      # @see Daru::IO::Importers::RData For .Rdata format
      class RDS < Base
        Daru::DataFrame.register_io_module :read_rds, self

        # Checks for required gem dependencies of RDS Importer
        def initialize
          optional_gem 'rsruby'
        end

        # Reads data from a rds file
        #
        # @param path [String] Path to rds file, where the dataframe is to be
        #   imported from.
        #
        # @return [Daru::IO::Importers::RDS]
        #
        # @example Reading from rds file
        #   instance = Daru::IO::Importers::RDS.read('bc_sites.rds')
        def read(path)
          @instance = RSRuby.instance.eval_R("readRDS('#{path}')")
          self
        end

        # Imports a `Daru::DataFrame` from a RDS Importer instance and rds file
        #
        # @return [Daru::DataFrame]
        #
        # @example Reading from a RDS file
        #   df = instance.call
        #
        #   #=> #<Daru::DataFrame(1113x25)>
        #   #         area descriptio  epa_reach format_ver   latitude   location location_c ...
        #   #  0      016  GSPTN             NaN        4.1       49.5    THOR IS 2MS22016 T ...
        #   #  1      012  CSPT              NaN        4.1    50.6167    MITC BY 2MN26012 M ...
        #   # ...     ...  ...               ...        ...       ...       ...       ...    ...
        def call
          process_dataframe(@instance)
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
