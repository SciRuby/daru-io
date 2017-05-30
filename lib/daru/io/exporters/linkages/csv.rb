require 'daru'

module Daru
  class DataFrame
    class << self
      def to_csv(opt={})
        exporters = Daru::IO::Exporters
        case opt[:gem]
        when :fastest_csv
          exporters::FastestCSV.load opt[:str]
        when :rcsv
          exporters::RCSV.load opt[:str]
        else
          exporters::CSV.load opt[:str]
        end
      end
    end
  end
end
