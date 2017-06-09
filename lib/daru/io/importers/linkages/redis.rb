require 'daru'

module Daru
  class DataFrame
    class << self
      def from_redis(connection={}, *keys)
        Daru::IO::Importers::Redis.new(connection, *keys).call
      end
    end
  end
end
