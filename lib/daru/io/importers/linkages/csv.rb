require 'daru'

module Daru
  class DataFrame
    class << self
      # Load data from a CSV file. Specify an optional block to grab the CSV
      # object and pre-condition it (for example use the `convert` or
      # `header_convert` methods).
      #
      # == Arguments
      #
      # * path - Local path / Remote URL of the file to load specified as a String.
      #
      # == Options
      #
      # Accepts the same options as the Daru::DataFrame constructor and CSV.open()
      # and uses those to eventually construct the resulting DataFrame.
      #
      # == Verbose Description
      #
      # You can specify all the options to the `.from_csv` function that you
      # do to the Ruby `CSV.read()` function, since this is what is used internally.
      #
      # For example, if the columns in your CSV file are separated by something
      # other that commas, you can use the `:col_sep` option. If you want to
      # convert numeric values to numbers and not keep them as strings, you can
      # use the `:converters` option and set it to `:numeric`.
      #
      # The `.from_csv` function uses the following defaults for reading CSV files
      # (that are passed into the `CSV.read()` function):
      #
      #   {
      #     :col_sep           => ',',
      #     :converters        => :numeric
      #   }
      def from_csv(path, opts={}, &block)
        # SPOILER ALERT
        #
        # When multiple CSV reading / writing libraries are to be integrated
        # into daru-io, have the user give the library in `opts`, such as :
        #
        # `Daru::DataFrame.from_csv path, other_opts, lib: :fastest_csv, &block` 
        #
        # The code below, should then look like
        #
        # ```
        # importers = Daru::IO::Importers
        # case opt[:gem]
        # when :fastest_csv
        #   importers::FastestCSV.load (...)
        # when :rcsv
        #   importers::RCSV.load (...)
        # else
        #   importers::CSV.load (...)
        # end
        # ```
        # 
        # Signed off by @athityakumar on 31/05/2017 at 9:30PM
        Daru::IO::Importers::CSV.load(path, opts, &block)
      end
    end
  end
end
