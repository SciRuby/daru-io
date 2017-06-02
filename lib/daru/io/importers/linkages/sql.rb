require 'daru'

module Daru
  class DataFrame
    class << self
      # Imports a *Daru::DataFrame* from a database query.
      #
      # @param dbh [DBI::DatabaseHandle, String] A DBI connection OR Path to a 
      #   SQlite3 database.
      # @param query [String] The query to be executed
      #
      # @return A *Daru::DataFrame* imported from the given query
      #
      # @example Reading from database with a DBI connection
      #   dbh = DBI.connect("DBI:Mysql:database:localhost", "user", "password")
      #   # Use the actual SQL credentials for the above line 
      #
      #   df = Daru::DataFrame.from_sql(dbh, "SELECT * FROM test")
      #   df
      #
      #   #=> #<Daru::DataFrame(2x3)>
      #   #=>        id  name   age
      #   #=>   0     1 Homer    20
      #   #=>   1     2 Marge    30
      #
      # @example Reading from a sqlite.db file
      #   require 'dbi'
      #   df = Daru::DataFrame.from_sql("path/to/sqlite.db", "SELECT * FROM test")
      #   df
      #
      #   #=> #<Daru::DataFrame(2x3)>
      #   #=>        id  name   age
      #   #=>   0     1 Homer    20
      #   #=>   1     2 Marge    30
      #
      # @see Daru::IO::Importers::SQL.load
      def from_sql(dbh, query)
        Daru::IO::Importers::SQL.load dbh, query
      end
    end
  end
end
