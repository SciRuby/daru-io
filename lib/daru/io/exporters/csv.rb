require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      # CSV Exporter Class, that extends `to_csv_string` and `write_csv` methods to
      # `Daru::DataFrame` instance variables
      class CSV < Base
        Daru::DataFrame.register_io_module :to_csv_string, self
        Daru::DataFrame.register_io_module :write_csv, self

        # Initializes a CSV Exporter instance
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export
        # @param converters [Symbol] A type to convert the data in dataframe
        # @param compression [Symbol] Defaults to `:infer`, which decides depending on file format
        #   like `.csv.gz`. For explicitly writing into a `.csv.gz` file, set
        #   `:compression` as `:gzip`.
        # @param headers [Boolean] When set to `false`, the headers aren't written
        #   to the CSV file
        # @param convert_comma [Boolean] When set to `true`, the decimal delimiter
        #   for float values is a comma (,) rather than a dot (.).
        # @param options [Hash] CSV standard library options, to tweak other
        #   default options of CSV gem.
        #
        # @example Initializing a CSV Exporter Instance
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      a   b
        #   #  0   1   3
        #   #  1   2   4
        #
        #   csv_instance = Daru::IO::Exporters::CSV.new(df, col_sep: ' ')
        #   csv_gz_instance = Daru::IO::Exporters::CSV.new(df, col_sep: ' ', compression: :gzip)
        def initialize(dataframe, converters: :numeric, compression: :infer,
          headers: nil, convert_comma: nil, **options)
          require 'csv'

          super(dataframe)
          @headers       = headers
          @compression   = compression
          @convert_comma = convert_comma
          @options       = options.merge converters: converters
        end

        # Exports a CSV Exporter instance to a file-writable String.
        #
        # @return [String] A file-writable string
        #
        # @example Getting a file-writable string from CSV Exporter instance
        #   csv_instance.to_s
        #   #=> "a b\n1 3\n2 4\n"
        #
        #   csv_gz_instance.to_s
        #   #=> "\u001F\x8B\b\u0000*D\xA4Y\u0000\u0003KTH\xE22T0\xE62R0\xE1\u0002\u0000\xF2\\\x96y\..."
        def to_s
          super
        end

        # Exports an Avro Exporter instance to a csv / csv.gz file.
        #
        # @param path [String] Path of the csv / csv.gz file where the dataframe is to be saved
        #
        # @example Writing an Avro Exporter instance to an Avro file
        #   csv_instance.write('filename.csv')
        #   csv_gz_instance.write('filename.csv.gz')
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
