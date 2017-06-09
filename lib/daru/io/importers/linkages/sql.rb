require 'daru'

module Daru
  class DataFrame
    class << self
      def from_sql(dbh, query)
        Daru::IO::Importers::SQL.new(dbh, query).load
      end
    end
  end
end
