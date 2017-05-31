require 'daru/io/importers/linkages/csv'

module Daru
  module IO
    module Importers
      module CSV
        class << self
          def load(path, opts={})
            daru_options, opts = CSVHelper.prepare_opts opts
            # Preprocess headers for detecting and correcting repetition in
            # case the :headers option is not specified.
            hsh =
              if opts[:headers]
                CSVHelper.hash_with_headers(path, opts)
              else
                CSVHelper
                  .hash_without_headers(path, opts)
                  .tap { |hash| daru_options[:order] = hash.keys }
              end
            Daru::DataFrame.new(hsh,daru_options)
          end
        end
      end
      module CSVHelper
        class << self
          OPT_KEYS = %i[clone order index name].freeze

          def prepare_opts(opts)
            opts[:col_sep]           ||= ','
            opts[:converters]        ||= :numeric

            daru_options = opts.keys.each_with_object({}) do |k, hash|
              hash[k] = opts.delete(k) if OPT_KEYS.include?(k)
            end
            [daru_options, opts]
          end

          def hash_with_headers(path, opts)
            opts[:header_converters] ||= :symbol
            ::CSV
              .parse(open(path), opts)
              .tap { |c| yield c if block_given? }
              .by_col.map { |col_name, values| [col_name, values] }.to_h
          end

          def hash_without_headers(path, opts)
            csv_as_arrays =
              ::CSV
              .parse(open(path), opts)
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
end
