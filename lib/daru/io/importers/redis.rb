require 'daru/io/importers/linkages/redis'
require 'daru/io/importers/base'
require 'json'

module Daru
  module IO
    module Importers
      class Redis
        def initialize(connection={}, *keys, match: nil, count: nil)
          @client  = get_client(connection)
          @pattern = match
          @count   = count
          @keys    = choose_keys(*keys).map(&:to_sym)
        end

        def call
          vals = @keys.map { |key| ::JSON.parse(@client.get(key), symbolize_names: true) }
          Base.guess_parse @keys, vals
        end

        private

        def choose_keys(*keys)
          if keys.count.zero?
            @client.scan(0, match: @pattern, count: @count).last
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
