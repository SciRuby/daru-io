require 'daru'

module Daru
  class DataFrame
    class << self
      # Exports *Daru::DataFrame* to a CSV file.
      #
      # @param filename [String] - Path of CSV file where the DataFrame is to be saved.
      # @param opts [Hash] - User-defined options, see below.
      #
      # @option opts convert_comma [Boolean] If set to *true*, will convert any commas
      #   in any of the data to full stops (.)
      #
      # @example Writing to a CSV file without options
      #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
      #
      #   #=> #<Daru::DataFrame(2x2)>
      #   #=>       a   b
      #   #=>   0   1   3
      #   #=>   1   2   4
      #
      #   df.write_csv "dataframe_df.csv"
      #
      # @example Writing to a CSV file with options
      #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
      #
      #   #=> #<Daru::DataFrame(2x2)>
      #   #=>       a   b
      #   #=>   0   1   3
      #   #=>   1   2   4
      #
      #   df.write_csv "dataframe_df.csv", convert_comma: true
      #
      # @note (For future maintainers of daru-io)
      #
      #   When multiple CSV reading / writing libraries are to be integrated
      #   into daru-io, have the user give the library in +opts+, such as :
      #
      #     Daru::DataFrame.to_csv path, other_opts, lib: :fastest_csv, &block
      #
      #   The code used inside, should then look like :
      #
      #     module Daru
      #       module DataFrame
      #         class << self
      #           def write_csv(filename, opts={})
      #             exporters = Daru::IO::exporters
      #             case opts[:gem]
      #             when :fastest_csv
      #               exporters::FastestCSV.write(self, filename, opts)
      #             when :rcsv
      #               exporters::RCSV.write(self, filename, opts)
      #             else
      #               exporters::CSV.write(self, filename, opts)
      #             end
      #           end
      #         end
      #       end
      #     end
      #
      #   Signed off by @athityakumar on 01/06/2017 at 10:30PM
      #
      # @see Daru::IO::Exporters::CSV.write
      def write_csv(filename, opts={})
        Daru::IO::Exporters::CSV.write(self, filename, opts)
      end
    end
  end
end
