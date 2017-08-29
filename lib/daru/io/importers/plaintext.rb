require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # Plaintext Importer Class, that extends `read_plaintext` method to
      # `Daru::DataFrame`
      class Plaintext < Base
        Daru::DataFrame.register_io_module :read_plaintext, self

        # Initializes a Plaintext Importer instance
        #
        # @param fields [Array] An array of vectors.
        #
        # @example Initializing with fields
        #   instance = Daru::IO::Importers::Plaintext.new([:v1, :v2, :v3, :v4, :v5, :v6])
        def initialize(fields)
          @fields = fields
        end

        # Imports a `Daru::DataFrame` from a Plaintext Importer instance and dat file
        #
        # @param path [String] Path to Plaintext file, where the dataframe is to be imported from.
        #
        # @return [Daru::DataFrame]
        #
        # @example Reading from a Plaintext file
        #   df = instance.read("bank2.dat")
        #
        #   #=> #<Daru::DataFrame(200x6)>
        #   #       v1    v2    v3    v4    v5    v6
        #   #  0 214.8 131.0 131.1   9.0   9.7 141.0
        #   #  1 214.6 129.7 129.7   8.1   9.5 141.7
        #   #  2 214.8 129.7 129.7   8.7   9.6 142.2
        #   #  3 214.8 129.7 129.6   7.5  10.4 142.0
        #   #  4 215.0 129.6 129.7  10.4   7.7 141.8
        #   #  5 215.7 130.8 130.5   9.0  10.1 141.4
        #   #  6 215.5 129.5 129.7   7.9   9.6 141.6
        #   #  7 214.5 129.6 129.2   7.2  10.7 141.7
        #   #  8 214.9 129.4 129.7   8.2  11.0 141.9
        #   #  9 215.2 130.4 130.3   9.2  10.0 140.7
        #   # 10 215.3 130.4 130.3   7.9  11.7 141.8
        #   # 11 215.1 129.5 129.6   7.7  10.5 142.2
        #   # 12 215.2 130.8 129.6   7.9  10.8 141.4
        #   # 13 214.7 129.7 129.7   7.7  10.9 141.7
        #   # 14 215.1 129.9 129.7   7.7  10.8 141.8
        #   #...   ...   ...   ...   ...   ...   ...
        def read(path)
          ds = Daru::DataFrame.new({}, order: @fields)
          File.open(path,'r').each_line do |line|
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
