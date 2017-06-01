require 'daru'

module Daru
  class DataFrame
    class << self
      # Read a database query and returns a Dataset
      #
      # @param dbh [DBI::DatabaseHandle, String] A DBI connection OR Path to a SQlite3 database.
      # @param query [String] The query to be executed
      #
      # @return A dataframe containing the data resulting from the query
      #
      # USE:
      #
      #  dbh = DBI.connect("DBI:Mysql:database:localhost", "user", "password")
      #  Daru::DataFrame.from_sql(dbh, "SELECT * FROM test")
      #
      #  #Alternatively
      #
      #  require 'dbi'
      #  Daru::DataFrame.from_sql("path/to/sqlite.db", "SELECT * FROM test")
      def from_sql(dbh, query)
        Daru::IO::Importers::SQL.load dbh, query
      end
    end
  end
end
