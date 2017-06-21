require 'daru/io/base'

module Daru
  module IO
    module Exporters
      class Base < Base
        def initialize(dataframe)
          if dataframe.is_a?(Daru::DataFrame)
            @dataframe = dataframe
          else
            raise ArgumentError,
              'Expected first argument to be a Daru::DataFrame, '\
              "received #{dataframe.class} instead."
          end
        end
      end
    end
  end
end
