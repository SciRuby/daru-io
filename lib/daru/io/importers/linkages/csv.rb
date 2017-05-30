require 'daru'

module Daru
  class DataFrame
    class << self
      def from_csv(opt={})
        importers = Daru::IO::Importers
        case opt[:gem]
        when :fastest_csv
          importers::FastestCSV.load opt[:str]
        when :rcsv
          importers::RCSV.load opt[:str]
        else
          importers::CSV.load opt[:str]
        end
      end
    end
  end
end
