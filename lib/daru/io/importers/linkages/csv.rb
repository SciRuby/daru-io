require 'daru'

module Daru
  class DataFrame
    class << self
      def from_csv(path, opts={}, &block)
        Daru::IO::Importers::CSV.new(path, opts, &block).load
      end
    end
  end
end
