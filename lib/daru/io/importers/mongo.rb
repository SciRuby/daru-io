require 'daru'
require 'daru/io/importers/json'

require 'mongo'
::Mongo::Logger.logger.level = ::Logger::FATAL

module Daru
  module IO
    module Importers
      class Mongo
        def initialize(connection, collection, *columns, order: nil, index: nil,
          **named_columns)
          @client        = get_client(connection)
          @collection    = collection.to_sym
          @columns       = columns
          @order         = order
          @index         = index
          @named_columns = named_columns
        end

        def call
          order = @client[@collection].find.map(&:keys)
          data  = @client[@collection].find.map(&:values)

          documents = []
          order.each_with_index { |o, i| documents.push(Hash[o.zip data[i]]) }

          JSON.new(
            documents,
            *@columns,
            order: @order,
            index: @index,
            **@named_columns
          ).call
        end

        private

        def get_client(connection)
          if connection.is_a? ::Mongo::Client
            connection
          elsif connection.is_a? Hash
            ip = connection.delete :ip
            ::Mongo::Client.new ip, connection
          elsif connection.is_a? String
            ::Mongo::Client.new connection
          end
        end
      end
    end
  end
end

require 'daru/io/link'
Daru::DataFrame.register_io_module :from_mongo, Daru::IO::Importers::Mongo
