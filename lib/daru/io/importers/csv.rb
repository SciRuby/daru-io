require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # CSV Importer Class, that extends `read_csv` method to `Daru::DataFrame`
      class CSV < Base
        Daru::DataFrame.register_io_module :read_csv, self

        CONVERTERS = {
          boolean: lambda { |f, _|
            case f.downcase.strip
            when 'true'  then true
            when 'false' then false
            else f
            end
          }
        }.freeze

        # Checks for required gem dependencies of CSV Importer
        def initialize
          require 'csv'
          require 'open-uri'
          require 'zlib'
        end

        # Reads data from a csv / csv.gz file
        #
        # @!method self.read(path)
        #
        # @param path [String] Path to csv / csv.gz file, where the dataframe is to be imported
        #   from.
        #
        # @return [Daru::IO::Importers::CSV]
        #
        # @example Reading from csv file
        #   instance = Daru::IO::Importers::CSV.read("matrix_test.csv")
        #
        # @example Reading from csv.gz file
        #   instance = Daru::IO::Importers::CSV.read("matrix_test.csv.gz")
        def read(path)
          @path      = path
          @file_data = open_data_source(@path)
          self
        end

        private def open_data_source(name)
          if name.respond_to?(:open)
            name.open
          elsif name.respond_to?(:to_str) &&
                %r{\A[A-Za-z][A-Za-z0-9+\-\.]*://} =~ name &&
                (uri = URI.parse(name)).respond_to?(:open)
            uri.open
          else
            File.open name
          end
        end

        # Imports a `Daru::DataFrame` from a CSV Importer instance
        #
        # @param headers [Boolean] If this option is `true`, only those columns
        #   will be used to import the `Daru::DataFrame` whose header is given.
        # @param skiprows [Integer] Skips the first `:skiprows` number of rows from
        #   the CSV file. Defaults to 0.
        # @param compression [Symbol] Defaults to `:infer`, to parse depending on file format
        #   like `.csv.gz`. For explicitly parsing data from a `.csv.gz` file, set
        #   `:compression` as `:gzip`.
        # @param clone [Boolean] Have a look at `:clone` option
        #   [here](http://www.rubydoc.info/gems/daru/0.1.5/Daru%2FDataFrame:initialize)
        # @param index [Array or Daru::Index or Daru::MultiIndex] Have a look at
        #   `:index` option
        #   [here](http://www.rubydoc.info/gems/daru/0.1.5/Daru%2FDataFrame:initialize)
        # @param order [Array or Daru::Index or Daru::MultiIndex] Have a look at
        #   `:order` option
        #   [here](http://www.rubydoc.info/gems/daru/0.1.5/Daru%2FDataFrame:initialize)
        # @param name [String] Have a look at `:name` option
        #   [here](http://www.rubydoc.info/gems/daru/0.1.5/Daru%2FDataFrame:initialize)
        # @param options [Hash] CSV standard library options such as `:col_sep`
        #   (defaults to `','`), `:converters` (defaults to `:numeric`),
        #   `:header_converters` (defaults to `:symbol`).
        #
        # @return [Daru::DataFrame]
        #
        # @example Calling with csv options
        #   df = instance.call(col_sep: ' ', headers: true)
        #
        #   #=> #<Daru::DataFrame(99x3)>
        #   #        image_reso        mls true_trans
        #   #      0    6.55779          0 -0.2362347
        #   #      1    2.14746          0 -0.1539447
        #   #      2    8.31104          0 0.3832846,
        #   #      3    3.47872          0 0.3832846,
        #   #      4    4.16725          0 -0.2362347
        #   #      5    5.79983          0 -0.2362347
        #   #      6     1.9058          0 -0.895577,
        #   #      7     1.9058          0 -0.2362347
        #   #      8    4.11806          0 -0.895577,
        #   #      9    6.26622          0 -0.2362347
        #   #     10    2.57805          0 -0.1539447
        #   #     11    4.76151          0 -0.2362347
        #   #     12    7.11002          0 -0.895577,
        #   #     13    5.40811          0 -0.2362347
        #   #     14    8.19567          0 -0.1539447
        #   #    ...        ...        ...        ...
        #
        # @example Calling with csv.gz options
        #   df = instance.call(compression: :gzip, col_sep: ' ', headers: true)
        #
        #   #=> #<Daru::DataFrame(99x3)>
        #   #        image_reso        mls true_trans
        #   #      0    6.55779          0 -0.2362347
        #   #      1    2.14746          0 -0.1539447
        #   #      2    8.31104          0 0.3832846,
        #   #      3    3.47872          0 0.3832846,
        #   #      4    4.16725          0 -0.2362347
        #   #      5    5.79983          0 -0.2362347
        #   #      6     1.9058          0 -0.895577,
        #   #      7     1.9058          0 -0.2362347
        #   #      8    4.11806          0 -0.895577,
        #   #      9    6.26622          0 -0.2362347
        #   #     10    2.57805          0 -0.1539447
        #   #     11    4.76151          0 -0.2362347
        #   #     12    7.11002          0 -0.895577,
        #   #     13    5.40811          0 -0.2362347
        #   #     14    8.19567          0 -0.1539447
        #   #    ...        ...        ...        ...
        def call(headers: nil, skiprows: 0, compression: :infer,
          clone: nil, index: nil, order: nil, name: nil, **options)
          init_opts(headers: headers, skiprows: skiprows, compression: compression,
                    clone: clone, index: index, order: order, name: name, **options)
          process_compression

          # Preprocess headers for detecting and correcting repetition in
          # case the :headers option is not specified.
          hsh =
            if @headers
              hash_with_headers
            else
              hash_without_headers.tap { |hash| @daru_options[:order] = hash.keys }
            end

          Daru::DataFrame.new(hsh, @daru_options)
        end

        private

        def compression?(algorithm, *formats)
          @compression == algorithm || formats.any? { |f| @path.end_with?(f) }
        end

        def hash_with_headers
          ::CSV
            .parse(@file_data, @options)
            .tap { |c| yield c if block_given? }
            .by_col
            .map do |col_name, values|
              [col_name, values.nil? ? [] : values[@skiprows..-1]]
            end
            .to_h
        end

        def hash_without_headers
          csv_as_arrays =
            ::CSV
            .parse(@file_data, @options)
            .tap { |c| yield c if block_given? }
            .to_a
          headers       = ArrayHelper.recode_repeated(csv_as_arrays.shift)
          csv_as_arrays = csv_as_arrays[@skiprows..-1].transpose
          headers
            .each_with_index
            .map do |h, i|
              [h, csv_as_arrays[i] || []]
            end
            .to_h
        end

        def init_opts(headers: nil, skiprows: 0, compression: :infer,
          clone: nil, index: nil, order: nil, name: nil, **options)
          @headers      = headers
          @skiprows     = skiprows
          @compression  = compression
          @daru_options = {clone: clone, index: index, order: order, name: name}
          @options      = {
            col_sep: ',', converters: [:numeric], header_converters: :symbol,
            headers: @headers, skip_blanks: true
          }.merge(options)

          @options[:converters] = @options[:converters].flat_map do |c|
            next ::CSV::Converters[c] if ::CSV::Converters[c]
            next CONVERTERS[c] if CONVERTERS[c]
            c
          end
        end

        def process_compression
          @file_data = ::Zlib::GzipReader.new(@file_data).read if compression?(:gzip, '.csv.gz')
        end
      end
    end
  end
end
