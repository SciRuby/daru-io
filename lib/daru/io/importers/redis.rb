require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # Redis Importer Class, that extends `from_redis` method to `Daru::DataFrame`
      class Redis < Base
        Daru::DataFrame.register_io_module :from_redis, self

        # Checks for required gem dependencies of Redis Importer
        def initialize
          require 'json'
          optional_gem 'redis'
        end

        # Loads data from a given connection
        #
        # @param connection [Hash or Redis Instance] Either a Hash of *Redis* configurations,
        #   or an existing *Redis* instance. For the hash configurations, have a
        #   look at
        #   [Redis#initialize](http://www.rubydoc.info/github/redis/redis-rb/Redis:initialize).
        #
        # @return [Daru::IO::Importers::Redis]
        #
        # @example Loading from a hash
        #   instance = Daru::IO::Importers::Redis.from({url: "redis://:[password]@[hostname]:[port]/[db]"})
        #
        # @example Loading from a Redis connection
        #   instance = Daru::IO::Importers::Redis.from(Redis.new({url: "redis://:[password]@[hostname]:[port]/[db]"}))
        def from(connection={})
          @client = get_client(connection)
          self
        end

        # Imports a `Daru::DataFrame` from a Redis Importer instance
        #
        # @param keys [Array] Redis key(s) from whom, the `Daru::DataFrame`
        #   should be constructed. If no keys are given, all keys in the *Redis*
        #   connection will be used.
        # @param match [String] A pattern to get matching keys.
        # @param count [Integer] Number of matching keys to be obtained. Defaults to
        #   nil, to collect ALL matching keys.
        #
        # @return [Daru::DataFrame]
        #
        # @example Importing with no options
        #   # Say, the Redis connection has this setup
        #   # Key "10001" => { "name" => "Tyrion", "age" => 32 }.to_json
        #   # Key "10002" => { "name" => "Jamie", "age" => 37 }.to_json
        #   # Key "10003" => { "name" => "Cersei", "age" => 37 }.to_json
        #   # Key "10004" => { "name" => "Joffrey", "age" => 19 }.to_json
        #
        #   df = instance.call
        #
        #   #=> <Daru::DataFrame(4x2)>
        #   #           name     age
        #   # 10001  Tyrion      32
        #   # 10002   Jamie      37
        #   # 10003  Cersei      37
        #   # 10004 Joffrey      19
        #
        # @example Importing with keys
        #   # Say, the Redis connection has this setup
        #   # Key "10001" => { "name" => "Tyrion", "age" => 32 }.to_json
        #   # Key "10002" => { "name" => "Jamie", "age" => 37 }.to_json
        #   # Key "10003" => { "name" => "Cersei", "age" => 37 }.to_json
        #   # Key "10004" => { "name" => "Joffrey", "age" => 19 }.to_json
        #
        #   df = instance.call("10001", "10002")
        #
        #   #=> <Daru::DataFrame(2x2)>
        #   #           name     age
        #   # 10001  Tyrion      32
        #   # 10002   Jamie      37
        #
        # @example Importing with query for matching keys and count
        #   # Say, the Redis connection has this setup
        #   # Key "key:1" => { "name" => "name1", "age" => "age1" }.to_json
        #   # Key "key:2" => { "name" => "name2", "age" => "age2" }.to_json
        #   # Key "key:3" => { "name" => "name3", "age" => "age3" }.to_json
        #   # ...
        #   # Key "key:2000" => { "name" => "name2000", "age" => "age2000" }.to_json
        #
        #   df = instance.call(match: "key:1*", count: 200)
        #
        #   #=> #<Daru::DataFrame(200x2)>
        #   #              name      age
        #   # key:1927 name1927  age1927
        #   # key:1759 name1759  age1759
        #   # key:1703 name1703  age1703
        #   # key:1640 name1640  age1640
        #   #   ...        ...      ...
        def call(*keys, match: nil, count: nil)
          @match  = match
          @count  = count
          @keys   = keys
          @keys   = choose_keys(*@keys).map(&:to_sym)

          vals = @keys.map { |key| ::JSON.parse(@client.get(key), symbolize_names: true) }
          Base.guess_parse(@keys, vals)
        end

        private

        def choose_keys(*keys)
          return keys.to_a unless keys.empty?

          cursor = nil
          # Loop to iterate through paginated results of Redis#scan.
          until cursor == '0' || (!@count.nil? && keys.count > (@count-1))
            cursor, chunk = @client.scan(cursor, match: @match, count: @count)
            keys.concat(chunk).uniq!
          end
          return keys[0..-1] if @count.nil?
          keys[0..@count-1]
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
