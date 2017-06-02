require 'daru'

module Daru
  class DataFrame
    class << self
      # Imports a *Daru::DataFrame* from a CSV file.
      #
      # @param path [String] Local / Remote path of CSV file, where the
      #   DataFrame is to be imported from.
      # @param opts [Hash] User-defined options, see below.
      #
      # @option opts col_sep [String] A column separator, to be used while
      #   importing from the CSV file. By default, it is set to ','
      # @option opts converters [Symbol] If set to +:numeric+, each value in
      #   the imported *Daru::DataFrame* will be numeric and not string.
      # @option opts headers [Boolean] If this option is used, only those columns
      #   will be used to import the *Daru::DataFrame* whose header is given.
      # @option opts header_converters [Symbol] If set to +:symbol+, the order of
      #   the imported *Daru::DataFrame* will be symbol (eg, +:name+) and not string.
      #
      # @return A *Daru::DataFrame* imported from the given relation and fields
      #
      # @example Reading from a CSV file from columns whose header is given
      #   df = Daru::DataFrame.from_csv("matrix_test.csv", col_sep: ' ', headers: true)
      #
      #   #=> #<Daru::DataFrame(99x3)>
      #   #=>           image_reso        mls true_trans
      #   #=>         0    6.55779          0 -0.2362347
      #   #=>         1    2.14746          0 -0.1539447
      #   #=>         2    8.31104          0 0.3832846,
      #   #=>         3    3.47872          0 0.3832846,
      #   #=>         4    4.16725          0 -0.2362347
      #   #=>         5    5.79983          0 -0.2362347
      #   #=>         6     1.9058          0 -0.895577,
      #   #=>         7     1.9058          0 -0.2362347
      #   #=>         8    4.11806          0 -0.895577,
      #   #=>         9    6.26622          0 -0.2362347
      #   #=>        10    2.57805          0 -0.1539447
      #   #=>        11    4.76151          0 -0.2362347
      #   #=>        12    7.11002          0 -0.895577,
      #   #=>        13    5.40811          0 -0.2362347
      #   #=>        14    8.19567          0 -0.1539447
      #   #=>       ...        ...        ...        ...
      #
      # @note (For future maintainers of daru-io)
      #
      #   When multiple CSV reading / writing libraries are to be integrated
      #   into daru-io, have the user give the library in +opts+, such as :
      #
      #     Daru::DataFrame.from_csv path, other_opts, lib: :fastest_csv, &block
      #
      #   The code used inside, should then look like :
      #
      #     module Daru
      #       module DataFrame
      #         class << self
      #           def from_csv(filename, opts={})
      #             importers = Daru::IO::importers
      #             case opts[:gem]
      #             when :fastest_csv
      #               importers::FastestCSV.load(filename, opts, &block)
      #             when :rcsv
      #               importers::RCSV.load(filename, opts, &block)
      #             else
      #               importers::CSV.load(filename, opts, &block)
      #             end
      #           end
      #         end
      #       end
      #     end
      #
      #   Signed off by @athityakumar on 31/05/2017 at 9:30PM
      #
      # @see Daru::IO::Importers::CSV.load
      def from_csv(path, opts={}, &block)
        Daru::IO::Importers::CSV.load(path, opts, &block)
      end
    end
  end
end
