require 'daru/io/exporters/linkages/csv'

module Daru
  module IO
    module Exporters
      class CSV
        def initialize(dataframe, path, converters: :numeric, headers: nil,
          convert_comma: nil, **options)
          @dataframe     = dataframe
          @path          = path
          @converters    = converters
          @headers       = headers
          @convert_comma = convert_comma
          @options       = options.merge(converters: @converters, headers: @headers)
        end

        def write
          writer = ::CSV.open(@path, 'w', @options)
          writer << @dataframe.vectors.to_a unless @headers == false

          @dataframe.each_row do |row|
            writer << if @convert_comma
                        row.map { |v| v.to_s.tr('.', ',') }
                      else
                        row.to_a
                      end
          end

          writer.close
        end
      end
    end
  end
end
