require 'daru/io/importers/linkages/redis'
require 'json'

module Daru
  module IO
    module Importers
      module Redis
        class << self
          def load(redis, *keys)
            client = RedisHelper.client redis
            keys   = RedisHelper.choose_keys client, *keys
            RedisHelper.parse_values(client, *keys)
          end
        end
      end
      module RedisHelper
        class << self
          def client(redis)
            if redis.is_a? ::Redis
              redis
            elsif redis.is_a? Hash
              ::Redis.new redis
            end
          end

          def choose_keys(client, *keys)
            if keys.count.zero?
              client.keys
            else
              keys.to_a
            end
          end

          def parse_values(client, *keys)
            vals = keys.map { |key| ::JSON.parse(client.get(key)) }

            case ::JSON.parse(client.get(keys[0]))
            when Array
              case ::JSON.parse(client.get(keys[0]))[0]
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
                Daru::DataFrame.rows vals.transpose, order: keys
              end
            when Hash
              # Array containing Hash
              # [
              #   key a: { x: 1, y: 2 }
              #   key b: { x: 3, y: 4 }
              # ]
              Daru::DataFrame.new vals.flatten, index: keys
            end
          end
        end
      end
    end
  end
end
