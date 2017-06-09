require 'daru'

module Daru
  class DataFrame
    class << self
      def from_excel(path, opts={}, &block)
        Daru::IO::Importers::Excel.new(path, opts, &block).load
      end
    end
  end
end
