require 'daru'
require 'daru/io/base'
require 'daru/io/importers/util'

require 'json'

module Daru
  module IO
    module Importers
      class Redis < Base
        # Imports a *Daru::DataFrame* from *Redis* connection and keys.
        #
        # @note In Redis, the specified key and count the number of queries that
        #   do not always fit perfectly. This persists in this module too,
        #   as this module is built on top of redis Ruby gem. Hence, if a query
        #   for 100 keys doesn't return exactly 100 keys, it is not a bug in
        #   this module. It is just how Redis works.
        #
        # @param connection [Hash or Redis Instance] Either a Hash of *Redis* configurations,
        #   or an existing *Redis* instance. For the hash configurations, have a
        #   look at {http://www.rubydoc.info/github/redis/redis-rb/Redis:initialize
        #   Redis#initialize}.
        # @param keys [Array] Redis key(s) from whom, the *Daru::DataFrame*
        #   should be constructed. If no keys are given, all keys in the *Redis*
        #   connection will be used.
        # @param match [String] A pattern to get matching keys.
        # @param count [Integer] Number of matching keys to be obtained.
        # @param page [Integer] The page of keys to be fetched from the
        #   paginated results of matching keys. Defaults to 0 (ie, First
        #   page results). For the i-th page results, pass the argument
        #   as i-1. When passed as a negative number, the whole pagination
        #   is traversed and ALL matching keys are used.
        #
        # @return A *Daru::DataFrame* imported from the given Redis connection
        #   and matching keys
        #
        # @example Importing with Redis configuration without specifying keys
        #   # Say, the Redis connection has this setup
        #   # Key "10001" => { "name" => "Tyrion", "age" => 32 }.to_json
        #   # Key "10002" => { "name" => "Jamie", "age" => 37 }.to_json
        #   # Key "10003" => { "name" => "Cersei", "age" => 37 }.to_json
        #   # Key "10004" => { "name" => "Joffrey", "age" => 19 }.to_json
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
        #   # Key "10001" => { "name" => "Tyrion", "age" => 32 }.to_json
        #   # Key "10002" => { "name" => "Jamie", "age" => 37 }.to_json
        #   # Key "10003" => { "name" => "Cersei", "age" => 37 }.to_json
        #   # Key "10004" => { "name" => "Joffrey", "age" => 19 }.to_json
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
        # @example Querying for matching keys with count
        #   # Say, the Redis connection has this setup
        #   # Key "timestamp:100620171225" => { "name" => "Joffrey", "age" => 19 }.to_json
        #   # Key "timestamp:090620171222" => { "name" => "Cersei",  "age" => 37 }.to_json
        #   # Key "timestamp:090620171218" => { "name" => "Jamie",   "age" => 37 }.to_json
        #   # Key "timestamp:090620171216" => { "name" => "Tyrion",  "age" => 32 }.to_json
        #
        #   # Say `connection` is a Redis instance
        #   df = Daru::DataFrame.from_redis(connection, match: "timestamp:09*", count: 3)
        #
        #   df
        #
        #   #=> <Daru::DataFrame(3x2)>
        #   #=>                               name     age
        #   #=>      timestamp:090620171222  Cersei      37
        #   #=>      timestamp:090620171218   Jamie      37
        #   #=>      timestamp:090620171216  Tyrion      32
        #
        def initialize(connection={}, *keys, match: nil, count: nil,
          page: 0)
          super(binding)
          @client = get_client(connection)
          @keys   = choose_keys(@keys).map(&:to_sym)
        end

        def call
          vals = @keys.map { |key| ::JSON.parse(@client.get(key), symbolize_names: true) }
          Util.guess_parse @keys, vals
        end

        private

        def choose_keys(keys)
          if keys.count.zero?
            cursor = 0
            page   = 0
            cursor, keys = @client.scan(cursor, match: @match, count: @count)
            return keys.uniq if @page.zero?

            # Loop to iterate through paginated results of Redis#scan
            # If @pages < 0 or @pages > total_pages, fetch ALL keys.
            # Else, fetch the particular page of keys.
            while not cursor.to_i.zero?
              response = @client.scan(cursor, match: @match, count: @count)
              return response.last.uniq if @page == (page+=1)
              cursor = response.first.to_i
              keys  += response.last
            end
            keys.uniq
          else
            keys.to_a
          end
        end

        def get_client(connection)
          if connection.is_a? ::Redis
            connection
          elsif connection.is_a? Hash
            ::Redis.new connection
          end
        end
      end
    end
  end
end

require 'daru/io/link'
Daru::DataFrame.register_io_module :from_redis, Daru::IO::Importers::Redis