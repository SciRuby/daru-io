require 'daru'
require 'daru/io/base'

module Daru
  module IO
    module Exporters
      class CSV < Base
        # Exports +Daru::DataFrame+ to a CSV file.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
        # @param path [String] Path of CSV file where the dataframe is to be saved
        # @param converters [Symbol] A type to convert the data in dataframe
        # @param headers [Boolean] When set to +false+, the headers aren't written
        #   to the CSV file
        # @param convert_comma [Boolean] When set to +true+, the commas are written
        #   as full-stops
        # @param options [Hash] CSV standard library options, to tweak other
        #   default options of CSV gem.
        #
        # @example Writing to a CSV file without options
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #=>       a   b
        #   #=>   0   1   3
        #   #=>   1   2   4
        #
        #   Daru::IO::Exporters::CSV.new(df, "filename.csv").call
        #
        # @example Writing to a CSV file with options
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #=>       a   b
        #   #=>   0   1   3
        #   #=>   1   2   4
        #
        #   Daru::IO::Exporters::CSV.new(df, "filename.csv", convert_comma: true).call
        def initialize(dataframe, path, converters: :numeric, headers: nil,
          convert_comma: nil, **options)
          super(binding)
          @options = @options.merge converters: @converters
        end

        def call
          writer = ::CSV.open(@path, 'w', @options)
          writer << @dataframe.vectors.to_a unless @headers == false

          @dataframe.each_row do |row|
            writer << if @convert_comma
                        row.map { |v| v.to_s.tr('.', ',') }
                      else
                        row.to_a
                      end
          end

          writer.close
        end
      end
    end
  end
end

require 'daru/io/link'
Daru::DataFrame.register_io_module :to_csv, Daru::IO::Exporters::CSV
