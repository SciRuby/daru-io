require 'daru'

module Daru
  class DataFrame
    class << self
      # Exports *Daru::DataFrame* to an Excel Spreadsheet.
      #
      # @param [String] filename The path of the file where the *Daru::DataFrame*
      #   should be written.
      # @param [Hash] opts A set of options, while writing the *Daru::DataFrame*.
      #
      # @example Writing to an Excel file without options
      #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
      #
      #   #=> #<Daru::DataFrame(2x2)>
      #   #=>       a   b
      #   #=>   0   1   3
      #   #=>   1   2   4
      #
      #   df.write_excel "dataframe_df.xls"
      #
      # @todo The +opts+ parameter isn't used while creating the Excel Spreadsheet yet.
      #   Implementing this feature will greatly allow the user to generate a Spreadsheet of
      #   their choice.
      #
      # @see Daru::IO::Exporters::Excel.write
      def write_excel(filename, opts={})
        Daru::IO::Exporters::Excel.new(self, filename, opts).write
      end
    end
  end
end
