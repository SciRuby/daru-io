require 'daru/io/importers/linkages/csv'

module Daru
  module IO
    module Importers
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
