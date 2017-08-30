require 'daru/io/importers/rds'

module Daru
  module IO
    module Importers
      # RData Importer Class, that extends `read_rdata` method to `Daru::DataFrame`
      #
      # @see Daru::IO::Importers::RDS For .rds format
      class RData < RDS
        Daru::DataFrame.register_io_module :read_rdata, self

        # Checks for required gem dependencies of RData Importer
        def initialize
          super
        end

        # Reads data from a Rdata file
        #
        # @param path [String] Path to RData file, where the dataframe is to be imported from.
        #
        # @return [Daru::IO::Importers::RData]
        #
        # @example Reading from rdata file
        #   instance = Daru::IO::Importers::RData.read('ACScounty.RData')
        def read(path)
          @instance = RSRuby.instance
          @instance.eval_R("load('#{path}')")
          self
        end

        # Imports a `Daru::DataFrame` from a RData Importer instance and rdata file
        #
        # @param variable [String] The variable to be imported from the
        #   variables stored in the RData file. Please note that the R
        #   variable to be imported from the RData file should be a
        #   `data.frame`
        #
        # @return [Daru::DataFrame]
        #
        # @example Importing a particular variable
        #   df = instance.call("ACS3")
        #
        #   #=>   #<Daru::DataFrame(1629x30)>
        #   #           Abbreviati       FIPS     Non.US      State       cnty females.di  ...
        #   #         0         AL       1001       14.7    alabama    autauga       13.8  ...
        #   #         1         AL       1003       13.5    alabama    baldwin       14.1  ...
        #   #         2         AL       1005       20.1    alabama    barbour       16.1  ...
        #   #         3         AL       1009       18.0    alabama     blount       13.7  ...
        #   #         4         AL       1015       18.6    alabama    calhoun       12.9  ...
        #   #       ...        ...        ...        ...        ...        ...        ...  ...
        def call(variable)
          @variable = variable.to_s

          validate_params

          process_dataframe(@instance.send(@variable.to_sym))
        end

        private

        def validate_params
          valid_r_dataframe_variables = @instance.eval_R('Filter(function(x) is.data.frame(get(x)) , ls())')
          return if valid_r_dataframe_variables.include?(@variable)

          variable_type = @instance.eval_R("typeof(#{@variable})")
          raise ArgumentError, "Expected the given R variable (#{@variable}) to be a data.frame, got a "\
                               "#{variable_type} instead."
        end
      end
    end
  end
end
