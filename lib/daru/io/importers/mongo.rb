require 'daru/io/importers/json'

module Daru
  module IO
    module Importers
      # Mongo Importer Class, that extends `from_mongo` method to `Daru::DataFrame`
      class Mongo < JSON
        Daru::DataFrame.register_io_module :from_mongo, self

        # Initializes a Mongo Importer instance
        #
        # @param collection [String or Symbol] A specific collection in the
        #   Mongo database, to import as `Daru::DataFrame`.
        # @param columns [Array] JSON-path slectors to select specific fields
        #   from the JSON input.
        # @param order [String or Array] Either a JSON-path selector string, or
        #   an array containing the order of the `Daru::DataFrame`. DO NOT
        #   provide both `order` and `named_columns` at the same time.
        # @param index [String or Array] Either a JSON-path selector string, or
        #   an array containing the order of the `Daru::DataFrame`.
        # @param filter [Hash] Filters and chooses Mongo documents that match
        #   the given `filter` from the collection.
        # @param limit [Interger] Limits the number of Mongo documents to be
        #   parsed from the collection.
        # @param skip [Integer] Skips `skip` number of documents from the Mongo
        #   collection.
        # @param named_columns [Hash] JSON-path selectors to select specific
        #   fields from the JSON input. DO NOT provide both `order` and
        #   `named_columns` at the same time.
        #
        # @note
        #   - For more information on using JSON-path selectors, have a look at
        #     the explanations {http://www.rubydoc.info/gems/jsonpath/0.5.8 here}
        #     and {http://goessner.net/articles/JsonPath/ here}.
        #   - The Mongo gem faces `Argument Error : expected Proc Argument`
        #     issue due to the bug in MRI Ruby 2.4.0 mentioned
        #     {https://bugs.ruby-lang.org/issues/13107 here}. This seems to have
        #     been fixed in Ruby 2.4.1 onwards. Hence, please avoid using this
        #     Mongo Importer in Ruby version 2.4.0.
        #
        # @example Initializing without jsonpath selectors
        #   # The below 'cars' collection can be recreated in a Mongo shell with -
        #   # db.cars.drop()
        #   # db.cars.insert({name: "Audi", price: 52642})
        #   # db.cars.insert({name: "Mercedes", price: 57127})
        #   # db.cars.insert({name: "Volvo", price: 29000})
        #
        #   instance_without_jsonpath = Daru::IO::Importers::Mongo.new('cars')
        #
        # @example Initializing with jsonpath selectors
        #   # The below 'cars' collection can be recreated in a Mongo shell with -
        #   # db.cars.drop()
        #   # db.cars.insert({name: "Audi", price: 52642, star: { fuel: 9.8, cost: 8.6, seats: 9.9, sound: 9.3 }})
        #   # db.cars.insert({name: "Mercedes", price: 57127, star: { fuel: 9.3, cost: 8.9, seats: 8.4, sound: 9.1 }})
        #   # db.cars.insert({name: "Volvo", price: 29000, star: { fuel: 7.8, cost: 9.9, seats: 8.2, sound: 8.9 }})
        #
        #   instance_with_jsonpath = Daru::IO::Importers::Mongo.new(
        #     'cars',
        #     '$.._id',
        #     '$..name',
        #     '$..price',
        #     '$..star..fuel',
        #     '$..star..cost'
        #   )
        def initialize
          super
          optional_gem 'mongo'
        end

        # Imports a `Daru::DataFrame` from a Mongo Importer instance.
        #
        # @param connection [String or Hash or Mongo::Client] Contains details
        #   about a Mongo database / hosts to connect.
        #
        # @return [Daru::DataFrame]
        #
        # @example Reading from a connection string
        #   df = instance_without_jsonpath.from('mongodb://127.0.0.1:27017/test')
        #
        #   #=> #<Daru::DataFrame(3x3)>
        #   #           _id       name      price
        #   #  0 5948d0bfcd       Audi    52642.0
        #   #  1 5948d0c6cd   Mercedes    57127.0
        #   #  2 5948d0cecd      Volvo    29000.0
        #
        # @example Reading from a connection hash
        #   df = instance_without_jsonpath.from({ hosts: ['127.0.0.1:27017'], database: 'test' })
        #
        #   #=> #<Daru::DataFrame(3x3)>
        #   #           _id       name      price
        #   #  0 5948d0bfcd       Audi    52642.0
        #   #  1 5948d0c6cd   Mercedes    57127.0
        #   #  2 5948d0cecd      Volvo    29000.0
        #
        # @example Reading from a Mongo::Client connection
        #   df = instance_with_jsonpath.from(Mongo::Client.new ['127.0.0.1:27017'], database: 'test')
        #
        #   #=> #<Daru::DataFrame(3x5)>
        #   #          _id       name      price       fuel       cost
        #   # 0 5948d40b50       Audi    52642.0        9.8        8.6
        #   # 1 5948d42850   Mercedes    57127.0        9.3        8.9
        #   # 2 5948d44350      Volvo    29000.0        7.8        9.9
        def from(connection)
          @client = get_client(connection)
          self
        end

        def call(collection, *columns, order: nil, index: nil,
          filter: nil, limit: nil, skip: nil, **named_columns)
          @file_string = @client[collection.to_sym]
                           .find(filter, skip: skip, limit: limit)
                           .to_json

          super(*columns, order: order, index: index, **named_columns)
        end

        private

        def get_client(connection)
          case connection
          when ::Mongo::Client
            connection
          when Hash
            hosts = connection.delete :hosts
            ::Mongo::Client.new(hosts, connection)
          when String
            ::Mongo::Client.new(connection)
          else
            raise ArgumentError,
              "Expected #{connection} to be either a Mongo instance, "\
              'Mongo connection Hash, or Mongo connection URL String. '\
              "Received #{connection.class} instead."
          end
        end
      end
    end
  end
end
