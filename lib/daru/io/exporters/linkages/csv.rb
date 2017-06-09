require 'daru'

module Daru
  class DataFrame
    class << self
      def write_csv(filename, opts={})
        Daru::IO::Exporters::CSV.new(self, filename, opts).write
      end
    end
  end
end
