require 'daru'

module Daru
  class DataFrame
    class << self
      def from_redis(redis_opts={}, *keys)
        Daru::IO::Importers::Redis.load redis_opts, *keys
      end
    end
  end
end
