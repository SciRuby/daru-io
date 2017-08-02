require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      class RDS < Base
        Daru::DataFrame.register_io_module :to_rds, self

        # Exports a +Daru::DataFrame+ to a RDS file.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
        # @param path [String] Path of RDS file where the dataframe(s) is/are to be saved
        # @param r_variable [String] Name of the R +data.frame+ variable name to be saved in the RDS file
        #
        # @example Writing to a RData file
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      a   b
        #   #  0   1   3
        #   #  1   2   4
        #
        #   Daru::IO::Exporters::RDS.new(df, "daru_dataframe.rds", "sample.dataframe").call
        def initialize(dataframe, path, r_variable)
          optional_gem 'rsruby'

          super(dataframe)
          @path       = path
          @r_variable = r_variable
        end

        def call
          @instance    = RSRuby.instance
          @statements  = process_statements(@r_variable, @dataframe)
          @statements << "saveRDS(#{@r_variable}, file='#{@path}')"
          @statements.each { |statement| @instance.eval_R(statement) }
        end

        private

        def process_statements(r_variable, dataframe)
          [].tap do |statement|
            dataframe.map_vectors_with_index do |vector, i|
              statement << "#{i} = c(#{vector.to_a.map { |val| convert_datatype(val) }.join(', ')})"
            end
            statement << "#{r_variable} = data.frame(#{dataframe.vectors.to_a.map(&:to_s).join(', ')})"
          end
        end

        def convert_datatype(value)
          return 'NA' unless value
          return value unless value.is_a?(String)
          "'#{value}'"
        end
      end
    end
  end
end
