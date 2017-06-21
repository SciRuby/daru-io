require 'daru'

require 'daru/io/importers/util'
require 'json'
require 'redis'

module Daru
  module IO
    module Importers
      class Redis
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
        # @param offset [Integer] An offset from which matching keys are to be
        #   fetched from the paginated results of matching keys. Defaults to 1.
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
        #   #           name     age
        #   # 10001  Tyrion      32
        #   # 10002   Jamie      37
        #   # 10003  Cersei      37
        #   # 10004 Joffrey      19
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
        #   #           name     age
        #   # 10001  Tyrion      32
        #   # 10002   Jamie      37
        #
        # @example Importing with Redis instance without specifying keys
        #   # Say, the Redis connection has this setup
        #   # Key "name"   => ["Tyrion", "Jamie", "Cersei", "Joffrey"]
        #   # Key "age"    => [32, 37, 37, 19]
        #   # Key "living" => [true, true, true, false]
        #
        #   connection = Redis.new({url: "redis://:[password]@[hostname]:[port]/[db]"})
        #   df         = Daru::DataFrame.from_redis(connection)
        #
        #   df
        #
        #   #=> <Daru::DataFrame(4x3)>
        #   #         name     age  living
        #   #    0  Tyrion      32    true
        #   #    1   Jamie      37    true
        #   #    2  Cersei      37    true
        #   #    3 Joffrey      19   false
        #
        # @example Importing with Redis instance by specifying keys
        #   # Say, the Redis connection has this setup
        #   # Key "name"   => ["Tyrion", "Jamie", "Cersei", "Joffrey"]
        #   # Key "age"    => [32, 37, 37, 19]
        #   # Key "living" => [true, true, true, false]
        #
        #   connection = Redis.new({url: "redis://:[password]@[hostname]:[port]/[db]"})
        #   df         = Daru::DataFrame.from_redis(connection, "name", "age")
        #
        #   df
        #
        #   #=> <Daru::DataFrame(4x2)>
        #   #         name     age
        #   #    0  Tyrion      32
        #   #    1   Jamie      37
        #   #    2  Cersei      37
        #   #    3 Joffrey      19
        #
        # @example Querying for matching keys with count and offset
        #   # Say, the Redis connection has this setup
        #   # Key "key:1" => { "name" => "name1", "age" => "age1" }.to_json
        #   # Key "key:2" => { "name" => "name2", "age" => "age2" }.to_json
        #   # Key "key:3" => { "name" => "name3", "age" => "age3" }.to_json
        #   # ...
        #   # Key "key:2000" => { "name" => "name2000", "age" => "age2000" }.to_json
        #
        #   connection = {url: "redis://:[password]@[hostname]:[port]/[db]"}
        #   Daru::DataFrame.from_redis(connection, match: "key:1*")
        #
        #   #=> #<Daru::DataFrame(1111x2)>
        #   #              name      age
        #   # key:1045 name1045  age1045
        #   # key:1919 name1919  age1919
        #   # key:1155 name1155  age1155
        #   # key:1649 name1649  age1649
        #   #      ...      ...      ...
        #
        #   Daru::DataFrame.from_redis({}, match: "key:1*", offset: 400, count: 200)
        #
        #   #=> #<Daru::DataFrame(200x2)>
        #   #              name      age
        #   # key:1927 name1927  age1927
        #   # key:1759 name1759  age1759
        #   # key:1703 name1703  age1703
        #   # key:1640 name1640  age1640
        #   #   ...        ...      ...
        #
        #   Daru::DataFrame.from_redis({}, match: "key:1*", offset: 1100, count: 200)
        #   #=> #<Daru::DataFrame(12x2)>
        #   #              name      age
        #   # key:1084 name1084  age1084
        #   # key:1195 name1195  age1195
        #   # key:1250 name1250  age1250
        #   # key:1303 name1303  age1303
        #   # key:1341 name1341  age1341
        #   #   ...        ...      ...
        def initialize(connection={}, *keys, match: nil, count: nil,
          offset: 1)
          @match  = match
          @count  = count
          @offset = offset-1
          @client = get_client(connection)
          @keys   = choose_keys(*keys).map(&:to_sym)
        end

        def call
          vals = @keys.map { |key| ::JSON.parse(@client.get(key), symbolize_names: true) }
          Util.guess_parse(@keys, vals)
        end

        private

        def choose_keys(*keys)
          if keys.count.zero?
            cursor = nil

            # Loop to iterate through paginated results of Redis#scan.
            until cursor == '0'
              response = @client.scan(cursor, match: @match, count: @count)
              cursor, chunk = response
              keys.concat(chunk).uniq!
              return keys[@offset..@offset+@count-1] unless @count.nil? || keys.count < (@offset+@count)
            end
            keys[@offset..-1]
          else
            keys.to_a
          end
        end

        def get_client(connection)
          case connection
          when ::Redis
            connection
          when Hash
            ::Redis.new connection
          else
            raise ArgumentError, "Expected '#{connection}' to be either "\
                                 'a Hash or an initialized Redis instance, '\
                                 "but received #{connection.class} instead."
          end
        end
      end
    end
  end
end

require 'daru/io/link'
Daru::DataFrame.register_io_module :from_redis, Daru::IO::Importers::Redis
