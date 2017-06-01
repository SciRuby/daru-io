require 'daru'

module Daru
  class DataFrame
    class << self
      # Load dataframe from AR::Relation
      #
      # @param relation [ActiveRecord::Relation] A relation to be used to load the contents of dataframe
      #
      # @return A dataframe containing the data in the given relation
      def from_activerecord(relation, *fields)
        Daru::IO::Importers::Activerecord.load relation, *fields
      end
    end
  end
end
