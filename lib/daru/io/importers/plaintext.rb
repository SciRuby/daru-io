require 'daru/io/importers/linkages/plaintext'

module Daru
  module IO
    module Importers
      class Plaintext
        def initialize(filename, fields)
          @filename = filename
          @fields   = fields
        end

        def load
          ds = Daru::DataFrame.new({}, order: @fields)
          File.open(@filename,'r').each_line do |line|
            row = process_row(line.strip.split(/\s+/),[''])
            next if row == ["\x1A"]
            ds.add_row(row)
          end
          ds.update
          @fields.each { |f| ds[f].rename f }
          ds
        end

        private

        INT_PATTERN = /^[-+]?\d+$/
        FLOAT_PATTERN = /^[-+]?\d+[,.]?\d*(e-?\d+)?$/

        def process_row(row,empty)
          row.to_a.map do |c|
            if empty.include?(c)
              # FIXME: As far as I can guess, it will never work.
              # It is called only inside `from_plaintext`, and there
              # data is splitted by `\s+` -- there is no chance that
              # "empty" (currently just '') will be between data?..
              nil
            else
              try_string_to_number(c)
            end
          end
        end

        def try_string_to_number(s)
          case s
          when INT_PATTERN
            s.to_i
          when FLOAT_PATTERN
            s.tr(',', '.').to_f
          else
            s
          end
        end
      end
    end
  end
end
