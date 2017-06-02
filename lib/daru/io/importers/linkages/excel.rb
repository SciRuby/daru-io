require 'daru'

module Daru
  class DataFrame
    class << self
      # Imports a *Daru::DataFrame* from an Excel file.
      #
      # @param path [String] Path of Excel file, where the
      #   DataFrame is to be imported from.
      # @param opts [Hash] User-defined options.
      #
      # @option opts worksheet_id [Integer] The index of the worksheet in the excel file,
      #   from where the *Daru::DataFrame* will be imported. By default, the first worksheet 
      #   has it's worksheet_id as 0. In general, the n-th worksheet has a worksheet_id as 
      #   n-1.
      #   
      #   If worksheet_id option is not given, it is taken as 0 by default and the 
      #   *Daru::DataFrame* will be imported from the first worksheet in the excel file.
      #
      # @return A *Daru::DataFrame* imported from the given excel worksheet
      #
      # @example Reading from a default worksheet of an Excel file
      #   df = Daru::DataFrame.from_excel("test_xls.xls")
      #   df
      #
      #   #=> #<Daru::DataFrame(6x5)>
      #   #=>               id     name      age     city       a1
      #   #=>       0        1     Alex       20 New York      a,b
      #   #=>       1        2   Claude       23   London      b,c
      #   #=>       2        3    Peter       25   London        a
      #   #=>       3        4    Franz      nil    Paris      nil
      #   #=>       4        5   George      5.5     Tome    a,b,c
      #   #=>       5        6  Fernand      nil      nil      nil
      #
      # @example Reading from a specific worksheet of an Excel file
      #   df = Daru::DataFrame.from_excel("test_xls.xls", worksheet_id: 0)
      #   df
      #
      #   #=> #<Daru::DataFrame(6x5)>
      #   #=>               id     name      age     city       a1
      #   #=>       0        1     Alex       20 New York      a,b
      #   #=>       1        2   Claude       23   London      b,c
      #   #=>       2        3    Peter       25   London        a
      #   #=>       3        4    Franz      nil    Paris      nil
      #   #=>       4        5   George      5.5     Tome    a,b,c
      #   #=>       5        6  Fernand      nil      nil      nil
      #
      # @see Daru::IO::Importers::Excel.load
      def from_excel(path, opts={}, &block)
        Daru::IO::Importers::Excel.load path, opts, &block
      end
    end
  end
end
