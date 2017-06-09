require 'daru'

module Daru
  class DataFrame
    class << self
      def from_activerecord(relation, *fields)
        Daru::IO::Importers::ActiveRecord.new(relation, *fields).load
      end
    end
  end
end
