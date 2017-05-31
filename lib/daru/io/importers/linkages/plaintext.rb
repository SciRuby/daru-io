require 'daru'

module Daru
  class DataFrame
    class << self
      # Read the database from a plaintext file. For this method to work,
      # the data should be present in a plain text file in columns. See
      # spec/fixtures/bank2.dat for an example.
      #
      # == Arguments
      #
      # * path - Path of the file to be read.
      # * fields - Vector names of the resulting database.
      #
      # == Usage
      #
      #   df = Daru::DataFrame.from_plaintext 'spec/fixtures/bank2.dat', [:v1,:v2,:v3,:v4,:v5,:v6]
      def from_plaintext(path, fields)
        Daru::IO.from_plaintext path, fields
      end
    end
  end
end
