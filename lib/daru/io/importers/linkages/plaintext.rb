require 'daru'

module Daru
  class DataFrame
    class << self
      def from_plaintext(path, fields)
        Daru::IO::Importers::Plaintext.new(path, fields).load
      end
    end
  end
end
