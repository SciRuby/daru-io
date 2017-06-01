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
        Daru::IO::Exporters::Excel.write self, filename, opts
      end
    end
  end
end
