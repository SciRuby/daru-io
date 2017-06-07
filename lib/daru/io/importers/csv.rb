require 'daru/io/importers/linkages/csv'

module Daru
  module IO
    module Importers
      class CSV
        def initialize(path, headers: nil, col_sep: ',', converters: :numeric,
          header_converters: :symbol, clone: nil, index: nil, order: nil,
          name: nil, **options)
          @path              = path
          @headers           = headers
          @col_sep           = col_sep
          @converters        = converters
          @header_converters = header_converters
          @daru_options      = {clone: clone, index: index, order: order, name: name}
          @options           = options.merge headers: @headers,
                                             col_sep: @col_sep,
                                             converters: @converters,
                                             header_converters: @header_converters
        end

        def load
          # Preprocess headers for detecting and correcting repetition in
          # case the :headers option is not specified.
          hsh =
            if @headers
              hash_with_headers
            else
              hash_without_headers.tap { |hash| @daru_options[:order] = hash.keys }
            end
          Daru::DataFrame.new(hsh,@daru_options)
        end

        private

        def hash_with_headers
          ::CSV
            .parse(open(@path), @options)
            .tap { |c| yield c if block_given? }
            .by_col.map { |col_name, values| [col_name, values] }.to_h
        end

        def hash_without_headers
          csv_as_arrays =
            ::CSV
            .parse(open(@path), @options)
            .tap { |c| yield c if block_given? }
            .to_a
          headers       = ArrayHelper.recode_repeated(csv_as_arrays.shift)
          csv_as_arrays = csv_as_arrays.transpose
          headers.each_with_index.map { |h, i| [h, csv_as_arrays[i]] }.to_h
        end
      end
    end
  end
end
