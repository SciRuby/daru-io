require 'daru'

module Daru
  class DataFrame
    class << self
      def from_html(path, fields={})
        Daru::IO::Importers::HTML.new(path, fields).load
      end
    end
  end
end
