require 'daru'

module Daru
  class DataFrame
    class << self
      # Imports a list of *Daru::DataFrame* s from a HTML file or website.
      #
      # @param path [String] Website URL / path to HTML file, where the
      #   DataFrame is to be imported from.
      # @param fields [Hash] User-defined options, see below.
      #
      # @option fields match [String] A *String* to match and choose a particular table(s)
      #   from multiple tables of a HTML page.
      # @option fields order [Array] By default, the order of the imported *Daru::DataFrame*
      #   is parsed by the module. Users can override the parsed order through this option.
      # @option fields index [Array] By default, the index of the imported *Daru::DataFrame*
      #   is parsed by the module. Users can override the parsed order through this option.
      # @option fields name [String] As +name+ of the imported *Daru::DataFrame* isn't
      #   parsed automatically by the module, users can set the name attribute to their
      #   *Daru::DataFrame* manually, through this option.
      #
      # @return A *Daru::DataFrame* imported from the given excel worksheet
      #
      # @example Reading from a website whose tables are static
      #   url = 'http://www.moneycontrol.com/'
      #   list_of_df = Daru::DataFrame.from_html(url, match: 'Sun Pharma')
      #   list_of_df.count
      #   #=> 4
      #
      #   df = list_of_df.first
      #   df
      #
      #   # As the website keeps changing everyday, the output might not be exactly the same
      #   # as the one obtained below. Nevertheless, a Daru::DataFrame should be obtained
      #   # as long as 'Sun Pharma' is there on the website.
      #
      #   #=> <Daru::DataFrame(5x4)>
      #   #=>          Company      Price     Change Value (Rs
      #   #=>     0 Sun Pharma     502.60     -65.05   2,117.87
      #   #=>     1   Reliance    1356.90      19.60     745.10
      #   #=>     2 Tech Mahin     379.45     -49.70     650.22
      #   #=>     3        ITC     315.85       6.75     621.12
      #   #=>     4       HDFC    1598.85      50.95     553.91
      #
      # @note
      #
      #   Please note that this module works only for static table elements on a
      #   HTML page, and won't work in cases where the data is being loaded into
      #   the HTML table by inline Javascript.
      #
      # @see Daru::IO::Importers::HTML.load
      def from_html(path, fields={})
        Daru::IO::Importers::HTML.load path, fields
      end
    end
  end
end
