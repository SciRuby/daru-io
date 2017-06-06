require 'daru'

module Daru
  class DataFrame
    class << self
      # Imports a *Daru::DataFrame* from an ActiveRecord Relation
      #
      # @param relation [ActiveRecord::Relation] A relation to be used to load
      #   the contents of DataFrame
      # @param fields [String or Array of Strings] A set of fields to load from.
      #
      # @return A *Daru::DataFrame* imported from the given relation and fields
      #
      # @example Importing from an ActiveRecord relation without specifying fields
      #   df = Daru::DataFrame.from_activerecord Account.all
      #   df
      #
      #   #=> #<Daru::DataFrame(2x3)>
      #   #=>        id  name   age
      #   #=>   0     1 Homer    20
      #   #=>   1     2 Marge    30
      #
      # @example Importing from an ActiveRecord relation by specifying fields
      #   df = Daru::DataFrame.from_activerecord Account.all, :id, :name
      #   df
      #
      #   #=> #<Daru::DataFrame(2x2)>
      #   #=>        id  name
      #   #=>   0     1 Homer
      #   #=>   1     2 Marge
      #
      # @see Daru::IO::Importers::Activerecord.load
      def from_activerecord(relation, *fields)
        Daru::IO::Importers::ActiveRecord.load relation, *fields
      end
    end
  end
end
