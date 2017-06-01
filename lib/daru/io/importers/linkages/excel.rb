require 'daru'

module Daru
  class DataFrame
    class << self
      # Read data from an Excel file into a DataFrame.
      #
      # == Arguments
      #
      # * path - Path of the file to be read.
      #
      # == Options
      #
      # *:worksheet_id - ID of the worksheet that is to be read.
      def from_excel(path, opts={}, &block)
        Daru::IO::Importers::Excel.load path, opts, &block
      end
    end
  end
end
