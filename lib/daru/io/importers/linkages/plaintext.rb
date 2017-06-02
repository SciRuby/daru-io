require 'daru'

module Daru
  class DataFrame
    class << self
      # Imports a *Daru::DataFrame* from a plaintext file.
      #
      # @param path [String] Path of plaintext file, where the
      #   DataFrame is to be imported from.
      # @param fields [Array] An array of vectors.
      #
      # @return A *Daru::DataFrame* imported from the given plaintext file
      #
      # @example Reading from a Plaintext file
      #   df = Daru::DataFrame.from_plaintext("bank2.dat", [:v1,:v2,:v3,:v4,:v5,:v6])
      #   df
      #
      #   #=> #<Daru::DataFrame(200x6)>
      #   #=>         v1    v2    v3    v4    v5    v6
      #   #=>    0 214.8 131.0 131.1   9.0   9.7 141.0
      #   #=>    1 214.6 129.7 129.7   8.1   9.5 141.7
      #   #=>    2 214.8 129.7 129.7   8.7   9.6 142.2
      #   #=>    3 214.8 129.7 129.6   7.5  10.4 142.0
      #   #=>    4 215.0 129.6 129.7  10.4   7.7 141.8
      #   #=>    5 215.7 130.8 130.5   9.0  10.1 141.4
      #   #=>    6 215.5 129.5 129.7   7.9   9.6 141.6
      #   #=>    7 214.5 129.6 129.2   7.2  10.7 141.7
      #   #=>    8 214.9 129.4 129.7   8.2  11.0 141.9
      #   #=>    9 215.2 130.4 130.3   9.2  10.0 140.7
      #   #=>   10 215.3 130.4 130.3   7.9  11.7 141.8
      #   #=>   11 215.1 129.5 129.6   7.7  10.5 142.2
      #   #=>   12 215.2 130.8 129.6   7.9  10.8 141.4
      #   #=>   13 214.7 129.7 129.7   7.7  10.9 141.7
      #   #=>   14 215.1 129.9 129.7   7.7  10.8 141.8
      #   #=>  ...   ...   ...   ...   ...   ...   ...
      #
      # @see Daru::IO::Importers::Plaintext.load
      def from_plaintext(path, fields)
        Daru::IO::Importers::Plaintext.load path, fields
      end
    end
  end
end
