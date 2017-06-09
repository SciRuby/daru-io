require 'daru'

module Daru
  class DataFrame
    class << self
      def write_excel(filename, opts={})
        Daru::IO::Exporters::Excel.new(self, filename, opts).write
      end
    end
  end
end
