require 'daru/io/base'

module Daru
  module IO
    module Exporters
      # Base Exporter Class that contains generic helper methods, to be
      # used by other Exporters via inheritence
      class Base < Daru::IO::Base
        # Checks whether the first argument given to any `Daru::IO::<Exporter>` module
        # is a **Daru::DataFrame**. Raises an error when it's not a **Daru::DataFrame**.
        #
        # @param dataframe [Daru::DataFrame] A DataFrame to initialize
        #
        # @example Stores the dataframe
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #   Daru::IO::Exporters::Base.new(df)
        #
        #   #=> #<Daru::IO::Exporters::Base:0x007f899081af08 @dataframe=#<Daru::DataFrame(2x2)>
        #   #      a   b
        #   #  0   1   3
        #   #  1   2   4>
        #
        # @example Raises error when not a DataFrame
        #   Daru::IO::Exporters::Base.new(nil)
        #
        #   #=> ArgumentError: Expected first argument to be a Daru::DataFrame, received NilClass instead
        def initialize(dataframe)
          unless dataframe.is_a?(Daru::DataFrame)
            raise ArgumentError,
              'Expected first argument to be a Daru::DataFrame, '\
              "received #{dataframe.class} instead."
          end
          @dataframe = dataframe
        end
      end
    end
  end
end
