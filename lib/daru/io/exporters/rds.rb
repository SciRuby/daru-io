require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      # RDS Exporter Class, that extends `to_rds_string` and `write_rds` methods to
      # `Daru::DataFrame` instance variables
      class RDS < Base
        Daru::DataFrame.register_io_module :to_rds_string, self
        Daru::DataFrame.register_io_module :write_rds, self

        # Initializes a RDS Exporter instance.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
        # @param r_variable [String] Name of the R `data.frame` variable name to be saved in the RDS file
        #
        # @example Initializing an RData Exporter
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      a   b
        #   #  0   1   3
        #   #  1   2   4
        #
        #   instance = Daru::IO::Exporters::RDS.new(df, "sample.dataframe")
        def initialize(dataframe, r_variable)
          optional_gem 'rsruby'

          super(dataframe)
          @r_variable = r_variable
        end

        # Exports a RDS Exporter instance to a file-writable String.
        #
        # @return [String] A file-writable string
        #
        # @example Getting a file-writable string from RDS Exporter instance
        #   instance.to_s #! same as df.to_rds_string("sample.dataframe")
        #
        #   #=> "\u001F\x8B\b\u0000\u0000\u0000\u0000\u0000\u0000\u0003\x8B\xE0b```b..."
        def to_s
          super
        end

        # Exports a RDS Exporter instance to a rds file.
        #
        # @param path [String] Path of RDS file where the dataframe is to be saved
        #
        # @example Writing an RDS Exporter instance to a rds file
        #   instance.write("daru_dataframe.rds")
        def write(path)
          @instance    = RSRuby.instance
          @statements  = process_statements(@r_variable, @dataframe)
          @statements << "saveRDS(#{@r_variable}, file='#{path}')"
          @statements.each { |statement| @instance.eval_R(statement) }
        end

        private

        def process_statements(r_variable, dataframe)
          [
            *dataframe.map_vectors_with_index do |vector, i|
              "#{i} = c(#{vector.to_a.map { |val| convert_datatype(val) }.join(', ')})"
            end,
            "#{r_variable} = data.frame(#{dataframe.vectors.to_a.map(&:to_s).join(', ')})"
          ]
        end

        def convert_datatype(value)
          case value
          when nil    then 'NA'
          when String then "'#{value}'"
          else value
          end
        end
      end
    end
  end
end
