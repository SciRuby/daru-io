require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      class RDS < Base
        Daru::DataFrame.register_io_module :from_rds, self

        # Imports a +Daru::DataFrame+ from a RDS file
        #
        # @param path [String] Path to RDS file
        #
        # @return A +Daru::DataFrame+ imported from the given RDS file
        #
        # @example Importing from a RDS file
        #   df = Daru::IO::Importers::RDS.new('bc_sites.rds').call
        #   df
        #
        #   #=> #<Daru::DataFrame(1113x25)>
        #   #         area descriptio  epa_reach format_ver   latitude   location location_c ...
        #   #  0      016  GSPTN             NaN        4.1       49.5    THOR IS 2MS22016 T ...
        #   #  1      012  CSPT              NaN        4.1    50.6167    MITC BY 2MN26012 M ...
        #   # ...     ...  ...               ...        ...       ...       ...       ...    ...
        def initialize(path)
          optional_gem 'rsruby'

          @path = path
        end

        def call
          Daru::DataFrame.new(
            RSRuby
              .instance.eval_R("readRDS('#{@path}')")
              .map { |k, v| [k.to_sym, v] }.to_h
          )
        end
      end
    end
  end
end
