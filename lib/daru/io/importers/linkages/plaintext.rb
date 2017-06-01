require 'daru'

module Daru
  class DataFrame
    class << self
      # Imports +Daru::DataFrame+ from a plaintext file. For this method to work,
      # the data should be present in a plain text file in columns. See
      # spec/fixtures/bank2.dat for an example.
      #
      # == Arguments
      #
      # * path - Path of the file to be read.
      # * fields - An *Array* of Vector names of the resulting *Daru::DataFrame*.
      #
      # == Usage
      #
      #   df = Daru::DataFrame.from_plaintext 'spec/fixtures/bank2.dat', [:v1,:v2,:v3,:v4,:v5,:v6]
      def from_plaintext(path, fields)
        Daru::IO::Importers::Plaintext.load path, fields
      end
    end
  end
end
