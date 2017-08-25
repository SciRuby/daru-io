require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      class CSV < Base
        Daru::DataFrame.register_io_module :to_csv_string, self
        Daru::DataFrame.register_io_module :write_csv, self

        # Exports +Daru::DataFrame+ to a CSV file.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
        # @param path [String] Path of CSV file where the dataframe is to be saved
        # @param converters [Symbol] A type to convert the data in dataframe
        # @param compression [Symbol] Defaults to +:infer+, which decides depending on file format
        #   like +.csv.gz+. For explicitly writing into a +.csv.gz+ file, set
        #   +:compression+ as +:gzip+.
        # @param headers [Boolean] When set to +false+, the headers aren't written
        #   to the CSV file
        # @param convert_comma [Boolean] When set to +true+, the decimal delimiter
        #   for float values is a comma (,) rather than a dot (.).
        # @param options [Hash] CSV standard library options, to tweak other
        #   default options of CSV gem.
        #
        # @example Writing to a CSV file without options
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      a   b
        #   #  0   1   3
        #   #  1   2   4
        #
        #   Daru::IO::Exporters::CSV.new(df, "filename.csv").call
        #
        # @example Writing to a CSV file with options
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      a   b
        #   #  0   1   3
        #   #  1   2   4
        #
        #   Daru::IO::Exporters::CSV.new(df, "filename.csv", convert_comma: true).call
        def initialize(dataframe, converters: :numeric, compression: :infer,
          headers: nil, convert_comma: nil, **options)
          require 'csv'

          super(dataframe)
          @headers       = headers
          @compression   = compression
          @convert_comma = convert_comma
          @options       = options.merge converters: converters
        end

        def write(path)
          @path    = path
          contents = process_dataframe

          if compression?(:gzip, '.csv.gz')
            require 'zlib'
            ::Zlib::GzipWriter.open(@path) do |gz|
              contents.each { |content| gz.write(content.to_csv(@options)) }
              gz.close
            end
          else
            csv = ::CSV.open(@path, 'w', @options)
            contents.each { |content| csv << content }
            csv.close
          end
        end

        private

        def compression?(algorithm, *formats)
          @compression == algorithm || formats.any? { |f| @path.end_with?(f) }
        end

        def process_dataframe
          [].tap do |result|
            result << @dataframe.vectors.to_a unless @headers == false
            @dataframe.map_rows do |row|
              next result << row.to_a unless @convert_comma
              result << row.map(&:to_s).map { |v| v =~ /^\d+./ ? v.tr('.',',') : v }
            end
          end
        end
      end
    end
  end
end
