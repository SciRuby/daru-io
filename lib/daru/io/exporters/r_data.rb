require 'daru/io/exporters/rds'

module Daru
  module IO
    module Exporters
      # RData Exporter Class, that can be used to export multiple `Daru::DataFrame`s
      # to a RData file
      class RData < RDS
        # Initializes a RData Exporter instance.
        #
        # @param options [Hash] A set of key-value pairs wherein the key depicts the name of
        #   the R `data.frame` variable name to be saved in the RData file, and the corresponding
        #   value depicts the `Daru::DataFrame` (or any Ruby variable in scope)
        #
        # @example Initializing RData Exporter instance
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
        #   instance = Daru::IO::Exporters::RData.new("first.df": df1, "second.df": df2)
        def initialize(**options)
          optional_gem 'rsruby'

          @options = options
        end

        # Exports a RData Exporter instance to a file-writable String.
        #
        # @return [String] A file-writable string
        #
        # @example Writing to a RData file
        #   instance.to_s
        #
        #   #=> "\u001F\x8B\b\u0000\u0000\u0000\u0000\u0000\u0000\u0003\vr\x890\xE2\x8A\xE0b```b..."
        def to_s
          super
        end

        # Exports an RData Exporter instance to a rdata file.
        #
        # @param path [String] Path of RData file where the dataframe(s) is/are to be saved
        #
        # @example Writing to a RData file
        #   instance.write("daru_dataframes.RData")
        def write(path)
          @instance    = RSRuby.instance
          @statements  = @options.map do |r_variable, dataframe|
            process_statements(r_variable, dataframe)
          end.flatten
          @statements << "save(#{@options.keys.map(&:to_s).join(', ')}, file='#{path}')"
          @statements.each { |statement| @instance.eval_R(statement) }
          true
        end
      end
    end
  end
end
