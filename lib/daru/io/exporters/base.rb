require 'daru/io/base'

module Daru
  module IO
    module Exporters
      class Base < Daru::IO::Base
        def initialize(dataframe)
          unless dataframe.is_a?(Daru::DataFrame)
            raise ArgumentError,
              'Expected first argument to be a Daru::DataFrame, '\
              "received #{dataframe.class} instead."\
          end
          @dataframe = dataframe
        end

        def to_s
          tempfile = Tempfile.new('tempfile')
          path     = tempfile.path
          write(path)

          File.read(path)
        end
      end
    end
  end
end
