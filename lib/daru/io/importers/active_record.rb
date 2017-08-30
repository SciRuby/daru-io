require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # ActiveRecord Importer Class, that extends `from_activerecord` method to
      # `Daru::DataFrame`
      class ActiveRecord < Base
        Daru::DataFrame.register_io_module :from_activerecord, self

        # Checks for required gem dependencies of ActiveRecord Importer
        def initialize
          optional_gem 'activerecord', '~> 4.0', requires: 'active_record'
        end

        # Loads data from a given relation
        #
        # @param relation [ActiveRecord::Relation] A relation to be used to load
        #   the contents of DataFrame
        #
        # @return [Daru::IO::Importers::ActiveRecord]
        #
        # @example Loading from a ActiveRecord instance
        #   instance = Daru::IO::Importers::ActiveRecord.from(Account.all)
        def from(relation)
          @relation = relation
          self
        end

        # Imports a `Daru::DataFrame` from an ActiveRecord Importer instance
        #
        # @param fields [String or Array of Strings] A set of fields to load from.
        #
        # @return [Daru::DataFrame]
        #
        # @example Importing from an instance without specifying fields
        #   instance.call
        #
        #   #=> #<Daru::DataFrame(2x3)>
        #   #=>        id  name   age
        #   #=>   0     1 Homer    20
        #   #=>   1     2 Marge    30
        #
        # @example Importing from an instance with specific fields
        #   instance.call(:id, :name)
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #=>        id  name
        #   #=>   0     1 Homer
        #   #=>   1     2 Marge
        def call(*fields)
          @fields = fields

          if @fields.empty?
            records = @relation.map { |record| record.attributes.symbolize_keys }
            return Daru::DataFrame.new(records)
          else
            @fields.map!(&:to_sym)
          end

          vectors = @fields.map { |name| [name, Daru::Vector.new([], name: name)] }.to_h

          Daru::DataFrame.new(vectors, order: @fields).tap do |df|
            @relation.pluck(*@fields).each do |record|
              df.add_row(Array(record))
            end
            df.update
          end
        end
      end
    end
  end
end
