require 'daru'

module Daru
  class DataFrame
    class << self
      # Write this DataFrame to a CSV file.
      #
      # == Arguements
      #
      # * filename - Path of CSV file where the DataFrame is to be saved.
      #
      # == Options
      #
      # * convert_comma - If set to *true*, will convert any commas in any
      # of the data to full stops ('.').
      # All the options accepted by CSV.read() can also be passed into this
      # function.
      def write_csv(filename, opts={})
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
        # Signed off by @athityakumar on 01/06/2017 at 10:30PM
        Daru::IO::Exporters::CSV.write(self, filename, opts)
      end
    end
  end
end
