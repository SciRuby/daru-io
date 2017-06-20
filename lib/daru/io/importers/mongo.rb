require 'daru'
require 'daru/io/importers/json'

require 'mongo'
::Mongo::Logger.logger.level = ::Logger::FATAL

module Daru
  module IO
    module Importers
      class Mongo
        # Imports a +Daru::DataFrame+ from a Mongo collection.
        #
        # @param connection [String or Hash or Mongo::Client] Contains details
        #   about a Mongo database / hosts to connect.
        # @param collection [String or Symbol] A specific collection in the
        #   Mongo database, to import as +Daru::DataFrame+.
        # @param columns [Array] JSON-path slectors to select specific fields
        #   from the JSON input.
        # @param order [String or Array] Either a JSON-path selector string, or
        #   an array containing the order of the +Daru::DataFrame+.
        # @param index [String or Array] Either a JSON-path selector string, or
        #   an array containing the order of the +Daru::DataFrame+.
        # @param named_columns [Hash] JSON-path slectors to select specific fields
        #   from the JSON input.
        #
        # @note For more information on using JSON-path selectors, have a look at
        #   the explanations {http://www.rubydoc.info/gems/jsonpath/0.5.8 here}
        #   and {http://goessner.net/articles/JsonPath/ here}.
        #
        # @return A +Daru::DataFrame+ imported from the given Mongo connection,
        #   collection and JSON-path selectors.
        #
        # @example Reading from a connection string without JSON-path selectors
        #
        #   # The below 'cars' collection can be recreated in a Mongo shell with -
        #   # db.cars.drop()
        #   # db.cars.insert({name: "Audi", price: 52642})
        #   # db.cars.insert({name: "Mercedes", price: 57127})
        #   # db.cars.insert({name: "Volvo", price: 29000})
        #
        #   connection = 'mongodb://127.0.0.1:27017/test'
        #   collection = 'cars'
        #   Daru::IO::Importers::Mongo.new(connection, collection).call
        #
        #   #=> #<Daru::DataFrame(3x3)>
        #   #           _id       name      price
        #   #  0 5948d0bfcd       Audi    52642.0
        #   #  1 5948d0c6cd   Mercedes    57127.0
        #   #  2 5948d0cecd      Volvo    29000.0
        #
        # @example Reading from a connection hash without JSON-path selectors
        #
        #   # The below 'cars' collection can be recreated in a Mongo shell with -
        #   # db.cars.drop()
        #   # db.cars.insert({name: "Audi", price: 52642})
        #   # db.cars.insert({name: "Mercedes", price: 57127})
        #   # db.cars.insert({name: "Volvo", price: 29000})
        #
        #   connection = { hosts: ['127.0.0.1:27017'], database: 'test' }
        #   collection = 'cars'
        #   Daru::IO::Importers::Mongo.new(connection, collection).call
        #
        #   #=> #<Daru::DataFrame(3x3)>
        #   #           _id       name      price
        #   #  0 5948d0bfcd       Audi    52642.0
        #   #  1 5948d0c6cd   Mercedes    57127.0
        #   #  2 5948d0cecd      Volvo    29000.0
        #
        # @example Reading from a Mongo::Client connection with JSON-path selectors
        #
        #   # The below 'cars' collection can be recreated in a Mongo shell with -
        #   # db.cars.drop()
        #   # db.cars.insert({name: "Audi", price: 52642, star: { fuel: 9.8, cost: 8.6, seats: 9.9, sound: 9.3 }})
        #   # db.cars.insert({name: "Mercedes", price: 57127, star: { fuel: 9.3, cost: 8.9, seats: 8.4, sound: 9.1 }})
        #   # db.cars.insert({name: "Volvo", price: 29000, star: { fuel: 7.8, cost: 9.9, seats: 8.2, sound: 8.9 }})
        #
        #   require 'mongo'
        #   connection = Mongo::Client.new ['127.0.0.1:27017'], database: 'test'
        #   collection = 'cars'
        #   Daru::IO::Importers::Mongo.new(
        #     connection,
        #     collection,
        #     '$.._id',
        #     '$..name',
        #     '$..price',
        #     '$..star..fuel',
        #     '$..star..cost'
        #   ).call
        #
        #   #=> #<Daru::DataFrame(3x5)>
        #   #          _id       name      price       fuel       cost
        #   # 0 5948d40b50       Audi    52642.0        9.8        8.6
        #   # 1 5948d42850   Mercedes    57127.0        9.3        8.9
        #   # 2 5948d44350      Volvo    29000.0        7.8        9.9
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
          data      = @client[@collection].find.map(&:values)
          orders    = @client[@collection].find.map(&:keys)
          documents = orders.map.with_index { |order, i| Hash[order.zip data[i]] }

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
            ip = connection.delete :hosts
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
