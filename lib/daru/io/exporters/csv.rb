require 'daru/io/exporters/linkages/csv'

module Daru
  module IO
    module Exporters
      module CSV
        class << self
          def load(str='CSV#load')
            CSVHelper.manipulate str
          end
        end
      end
      module CSVHelper
        class << self
          def manipulate(str)
            "CSVHelper#manipulate called by #{str}"
          end
        end
      end
    end
  end
end
