require 'daru/io/exporters/linkages/csv'

module Daru
  module IO
    module Exporters
      module RCSV
        class << self
          def load(str='RCSV#load')
            RCSVHelper.manipulate str
          end
        end
      end
      module RCSVHelper
        class << self
          def manipulate(str)
            "RCSVHelper#manipulate called by #{str}"
          end
        end
      end
    end
  end
end
