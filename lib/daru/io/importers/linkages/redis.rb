require 'daru'

module Daru
  class DataFrame
    class << self
      def from_redis(redis_opts={}, *keys)
        Daru::IO::Importers::Redis.new(redis_opts, *keys).load
      end
    end
  end
end
