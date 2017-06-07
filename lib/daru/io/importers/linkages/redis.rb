require 'daru'

module Daru
  class DataFrame
    class << self
      # Imports a *Daru::DataFrame* from *Redis* connection and keys.
      #
      # @param connection [Hash or Redis Instance] Either a Hash of *Redis* configurations,
      #   or an existing *Redis* instance. For the hash configurations, have a
      #   look at {http://www.rubydoc.info/github/redis/redis-rb/Redis:initialize
      #   Redis#initialize}.
      # @param keys [Array] Redis key(s) from whom, the *Daru::DataFrame*
      #   should be constructed. If no keys are given, all keys in the *Redis*
      #   connection will be used.
      #
      # @return A *Daru::DataFrame* imported from the given Redis connection
      #   and keys
      #
      # @example Importing with Redis configuration without specifying keys
      #   # Say, the Redis connection has this setup
      #   # Key "10001" => { "name" => "Tyrion", "age" => 32 }
      #   # Key "10002" => { "name" => "Jamie", "age" => 37 }
      #   # Key "10003" => { "name" => "Cersei", "age" => 37 }
      #   # Key "10004" => { "name" => "Joffrey", "age" => 19 }
      #
      #   connection = {url: "redis://:[password]@[hostname]:[port]/[db]"}
      #   df         = Daru::DataFrame.from_redis(connection)
      #
      #   df
      #
      #   #=> <Daru::DataFrame(4x2)>
      #   #=>             name     age
      #   #=>   10001  Tyrion      32
      #   #=>   10002   Jamie      37
      #   #=>   10003  Cersei      37
      #   #=>   10004 Joffrey      19
      #
      # @example Importing with Redis configuration by specifying keys
      #   # Say, the Redis connection has this setup
      #   # Key "10001" => { "name" => "Tyrion", "age" => 32 }
      #   # Key "10002" => { "name" => "Jamie", "age" => 37 }
      #   # Key "10003" => { "name" => "Cersei", "age" => 37 }
      #   # Key "10004" => { "name" => "Joffrey", "age" => 19 }
      #
      #   connection = {url: "redis://:[password]@[hostname]:[port]/[db]"}
      #   df         = Daru::DataFrame.from_redis(connection, "10001", "10002")
      #
      #   df
      #
      #   #=> <Daru::DataFrame(2x2)>
      #   #=>             name     age
      #   #=>   10001  Tyrion      32
      #   #=>   10002   Jamie      37
      #
      # @example Importing with Redis instance without specifying keys
      #   # Say, the Redis connection has this setup
      #   # Key "name"   => ["Tyrion", "Jamie", "Cersei", "Joffrey"]
      #   # Key "age"    => [32, 37, 37, 19]
      #   # Key "living" => [true, true, true, false]
      #
      #   # Say `connection` is a Redis instance
      #   df         = Daru::DataFrame.from_redis(connection)
      #
      #   df
      #
      #   #=> <Daru::DataFrame(4x3)>
      #   #=>           name     age  living
      #   #=>      0  Tyrion      32    true
      #   #=>      1   Jamie      37    true
      #   #=>      2  Cersei      37    true
      #   #=>      3 Joffrey      19   false
      #
      # @example Importing with Redis instance by specifying keys
      #   # Say, the Redis connection has this setup
      #   # Key "name"   => ["Tyrion", "Jamie", "Cersei", "Joffrey"]
      #   # Key "age"    => [32, 37, 37, 19]
      #   # Key "living" => [true, true, true, false]
      #
      #   # Say `connection` is a Redis instance
      #   df         = Daru::DataFrame.from_redis(connection, "name", "age")
      #
      #   df
      #
      #   #=> <Daru::DataFrame(4x2)>
      #   #=>           name     age
      #   #=>      0  Tyrion      32
      #   #=>      1   Jamie      37
      #   #=>      2  Cersei      37
      #   #=>      3 Joffrey      19
      #
      # @see Daru::IO::Importers::Redis
      def from_redis(connection={}, *keys)
        Daru::IO::Importers::Redis.new(connection, *keys).load
      end
    end
  end
end
