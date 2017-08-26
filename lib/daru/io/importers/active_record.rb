require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # ActiveRecord Importer Class, that extends `from_activerecord` method to
      # `Daru::DataFrame`
      class ActiveRecord < Base
        Daru::DataFrame.register_io_module :from_activerecord, self

        # Imports a `Daru::DataFrame` from an ActiveRecord Relation
        #
        # @param relation [ActiveRecord::Relation] A relation to be used to load
        #   the contents of DataFrame
        # @param fields [String or Array of Strings] A set of fields to load from.
        #
        # @return A `Daru::DataFrame` imported from the given relation and fields
        #
        # @example Importing from an ActiveRecord relation without specifying fields
        #   df = Daru::IO::Importers::ActiveRecord.new(Account.all).call
        #   df
        #
        #   #=> #<Daru::DataFrame(2x3)>
        #   #=>        id  name   age
        #   #=>   0     1 Homer    20
        #   #=>   1     2 Marge    30
        #
        # @example Importing from an ActiveRecord relation by specifying fields
        #   df = Daru::IO::Importers::ActiveRecord.new(Account.all, :id, :name).call
        #   df
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #=>        id  name
        #   #=>   0     1 Homer
        #   #=>   1     2 Marge
        def initialize(*fields)
          optional_gem 'activerecord', '~> 4.0', requires: 'active_record'

          @fields = fields
        end

        def from(relation)
          if @fields.empty?
            records = relation.map { |record| record.attributes.symbolize_keys }
            return Daru::DataFrame.new(records)
          else
            @fields.map!(&:to_sym)
          end

          vectors = @fields.map { |name| [name, Daru::Vector.new([], name: name)] }.to_h

          Daru::DataFrame.new(vectors, order: @fields).tap do |df|
            relation.pluck(*@fields).each do |record|
              df.add_row(Array(record))
            end
            df.update
          end
        end
      end
    end
  end
end
