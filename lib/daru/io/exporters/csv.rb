require 'daru/io/exporters/linkages/csv'

module Daru
  module IO
    module Exporters
      module CSV
        class << self
          def write(dataframe, path, opts={})
            options = {
              converters: :numeric
            }.merge(opts)

            writer = ::CSV.open(path, 'w', options)
            writer << dataframe.vectors.to_a unless options[:headers] == false

            dataframe.each_row do |row|
              writer << if options[:convert_comma]
                          row.map { |v| v.to_s.tr('.', ',') }
                        else
                          row.to_a
                        end
            end

            writer.close
          end
        end
      end
      module CSVHelper
        class << self
        end
      end
    end
  end
end
