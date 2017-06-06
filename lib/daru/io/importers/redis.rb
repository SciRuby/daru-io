require 'daru/io/importers/linkages/redis'
require 'json'

module Daru
  module IO
    module Importers
      class Redis
        def choose_keys(*keys)
          if keys.count.zero?
            @client.keys
          else
            keys.to_a
          end
        end

        def get_client(redis)
          if redis.is_a? ::Redis
            redis
          elsif redis.is_a? Hash
            ::Redis.new redis
          end
        end

        def initialize(redis, *keys)
          @client = get_client(redis)
          @keys   = choose_keys(*keys)
        end

        def load
          vals = @keys.map { |key| ::JSON.parse(@client.get(key)) }

          case ::JSON.parse(@client.get(@keys[0]))
          when Array
            case ::JSON.parse(@client.get(@keys[0]))[0]
            when Hash
              # Array of hashes
              # key a :
              # [
              #   { x: 1, y: 2 },
              #   { x: 3, y: 4 }
              # ]
              Daru::DataFrame.new vals.flatten
            else
              # Hash containing Array
              # key a :
              # {
              #   x: [1,2,3,4]
              #   y: [5,6,7,8]
              # }
              Daru::DataFrame.rows vals.transpose, order: @keys
            end
          when Hash
            # Array containing Hash
            # [
            #   key a: { x: 1, y: 2 }
            #   key b: { x: 3, y: 4 }
            # ]
            Daru::DataFrame.new vals.flatten, index: @keys
          end
        end
      end
    end
  end
end
