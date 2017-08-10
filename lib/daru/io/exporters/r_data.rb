require 'daru/io/exporters/rds'

module Daru
  module IO
    module Exporters
      # RData Exporter Class, that extends +to_rdata+ method to +Daru::DataFrame+
      # instance variables
      class RData < RDS
        # Exports single / multiple +Daru::DataFrame+s to a RData file.
        #
        # @param path [String] Path of RData file where the dataframe(s) is/are to be saved
        # @param options [Hash] A set of key-value pairs wherein the key depicts the name of
        #   the R +data.frame+ variable name to be saved in the RData file, and the corresponding
        #   value depicts the +Daru::DataFrame+ (or any Ruby variable in scope)
        #
        # @example Writing to a RData file
        #   df1 = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      a   b
        #   #  0   1   3
        #   #  1   2   4
        #
        #   df2 = Daru::DataFrame.new([[5,6],[7,8]], order: [:x, :y])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      x   y
        #   #  0   5   7
        #   #  1   6   8
        #
        #   Daru::IO::Exporters::RData.new("daru_dataframes.RData", "first.df": df1, "second.df": df2).call
        def initialize(path, **options)
          optional_gem 'rsruby'

          @path    = path
          @options = options
        end

        def call
          @instance    = RSRuby.instance
          @statements  = @options.map do |r_variable, dataframe|
            process_statements(r_variable, dataframe)
          end.flatten
          @statements << "save(#{@options.keys.map(&:to_s).join(', ')}, file='#{@path}')"
          @statements.each { |statement| @instance.eval_R(statement) }
        end
      end
    end
  end
end
