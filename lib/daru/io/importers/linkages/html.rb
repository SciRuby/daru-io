require 'daru'

module Daru
  class DataFrame
    class << self
      # Read the table data from a remote html file. Please note that this module
      # works only for static table elements on a HTML page, and won't work in
      # cases where the data is being loaded into the HTML table by Javascript.
      #
      # By default - all <th> tag elements in the first proper row are considered
      # as the order, and all the <th> tag elements in the first column are
      # considered as the index.
      #
      # == Arguments
      #
      # * path [String] - URL of the target HTML file.
      # * fields [Hash] -
      #
      #   +:match+ - A *String* to match and choose a particular table(s) from multiple tables of a HTML page.
      #
      #   +:order+ - An *Array* which would act as the user-defined order, to override the parsed *Daru::DataFrame*.
      #
      #   +:index+ - An *Array* which would act as the user-defined index, to override the parsed *Daru::DataFrame*.
      #
      #   +:name+ - A *String* that manually assigns a name to the scraped *Daru::DataFrame*, for user's preference.
      #
      # == Returns
      # An Array of +Daru::DataFrame+s, with each dataframe corresponding to a
      # HTML table on that webpage.
      #
      # == Usage
      #   dfs = Daru::DataFrame.from_html("http://www.moneycontrol.com/", match: "Sun Pharma")
      #   dfs.count
      #   # => 4
      #
      #   dfs.first
      #   #
      #   # => <Daru::DataFrame(5x4)>
      #   #          Company      Price     Change Value (Rs
      #   #     0 Sun Pharma     502.60     -65.05   2,117.87
      #   #     1   Reliance    1356.90      19.60     745.10
      #   #     2 Tech Mahin     379.45     -49.70     650.22
      #   #     3        ITC     315.85       6.75     621.12
      #   #     4       HDFC    1598.85      50.95     553.91
      def from_html(path, fields={})
        Daru::IO::Importers::HTML.load path, fields
      end
    end
  end
end
