require 'daru'

module Daru
  class DataFrame
    class << self
      # Write this dataframe to an Excel Spreadsheet
      #
      # == Arguments
      #
      # * filename - The path of the file where the DataFrame should be written.
      def write_excel(filename, opts={})
        # SPOILER ALERT
        #
        # When multiple CSV reading / writing libraries are to be integrated
        # into daru-io, have the user give the library in `opts`, such as :
        #
        # `Daru::DataFrame.to_csv path, other_opts, lib: :fastest_csv, &block`
        #
        # The code below, should then look like
        #
        # ```
        # exporters = Daru::IO::exporters
        # case opt[:gem]
        # when :fastest_csv
        #   exporters::FastestCSV.write (...)
        # when :rcsv
        #   exporters::RCSV.write (...)
        # else
        #   exporters::CSV.write (...)
        # end
        # ```
        #
        # Signed off by @athityakumar on 01/06/2017 at 9:10PM
        Daru::IO::Exporters::Excel.write self, filename, opts
      end
    end
  end
end
