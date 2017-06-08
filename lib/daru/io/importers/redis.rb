require 'daru/io/importers/linkages/redis'
require 'json'

module Daru
  module IO
    module Importers
      class Redis
        def initialize(connection={}, *keys)
          @client = get_client(connection)
          @keys   = choose_keys(*keys).map(&:to_sym)
        end

        def call
          vals = @keys.map { |key| ::JSON.parse(@client.get(key), symbolize_names: true) }
          Base.guess_parse @keys, vals
        end

        private

        def choose_keys(*keys)
          if keys.count.zero?
            @client.keys
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
