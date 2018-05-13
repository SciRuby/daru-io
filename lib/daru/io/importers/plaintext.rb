require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # Plaintext Importer Class, that extends `read_plaintext` method to
      # `Daru::DataFrame`
      class Plaintext < Base
        Daru::DataFrame.register_io_module :read_plaintext, self

        # Checks for required gem dependencies of Plaintext Importer
        def initialize; end

        # Reads data from a plaintext (.dat) file
        #
        # @!method self.read(path)
        #
        # @param path [String] Path to plaintext file, where the dataframe is to be
        #   imported from.
        #
        # @return [Daru::IO::Importers::Plaintext]
        #
        # @example Reading from plaintext file
        #   instance = Daru::IO::Importers::Plaintext.read("bank2.dat")
        def read(path)
          @file_data = File.read(path).split("\n").map do |line|
            row = process_row(line.strip.split(/\s+/),[''])
            next if row == ["\x1A"]
            row
          end
          self
        end

        # Imports `Daru::DataFrame` from a Plaintext Importer instance
        #
        # @param fields [Array] An array of vectors.
        #
        # @return [Daru::DataFrame]
        #
        # @example Initializing with fields
        #   df = instance.call([:v1, :v2, :v3, :v4, :v5, :v6])
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
        def call(fields)
          Daru::DataFrame.rows(@file_data, order: fields)
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

        def try_string_to_number(str)
          case str
          when INT_PATTERN
            str.to_i
          when FLOAT_PATTERN
            str.tr(',', '.').to_f
          else
            str
          end
        end
      end
    end
  end
end
