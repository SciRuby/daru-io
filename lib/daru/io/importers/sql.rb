require 'daru'
require 'daru/io/base'

module Daru
  module IO
    module Importers
      class SQL < Base
        # Imports a +Daru::DataFrame+ from a SQL query.
        #
        # @param dbh [DBI::DatabaseHandle or String] A DBI connection OR Path to a
        #   SQlite3 database.
        # @param query [String] The query to be executed
        #
        # @return A +Daru::DataFrame+ imported from the given query
        #
        # @example Reading from database with a DBI connection
        #   dbh = DBI.connect("DBI:Mysql:database:localhost", "user", "password")
        #   # Use the actual SQL credentials for the above line
        #
        #   df = Daru::IO::Importers::SQL.new(dbh, "SELECT * FROM test").call
        #   df
        #
        #   #=> #<Daru::DataFrame(2x3)>
        #   #=>        id  name   age
        #   #=>   0     1 Homer    20
        #   #=>   1     2 Marge    30
        #
        # @example Reading from a sqlite.db file
        #   require 'dbi'
        #
        #   path = 'path/to/sqlite.db'
        #   df = Daru::IO::Importers::SQL.new(path, "SELECT * FROM test").call
        #   df
        #
        #   #=> #<Daru::DataFrame(2x3)>
        #   #=>        id  name   age
        #   #=>   0     1 Homer    20
        #   #=>   1     2 Marge    30
        def initialize(dbh, query)
          super(binding)
        end

        def call
          @conn, @adapter = choose_adapter @dbh, @query
          df_hash         = result_hash
          Daru::DataFrame.new(df_hash).tap(&:update)
        end

        private

        def result_hash
          column_names
            .map(&:to_sym)
            .zip(rows.transpose)
            .to_h
        end

        def column_names
          case @adapter
          when :dbi
            result.column_names
          when :activerecord
            result.columns
          end
        end

        def rows
          case @adapter
          when :dbi
            result.to_a.map(&:to_a)
          when :activerecord
            result.cast_values
          end
        end

        def result
          case @adapter
          when :dbi
            @conn.execute(@query)
          when :activerecord
            @conn.exec_query(@query)
          end
        end

        def choose_adapter(db, query)
          query = String.try_convert(query) or
            raise ArgumentError, "Query must be a string, #{query.class} received"

          db = attempt_sqlite3_connection(db) if db.is_a?(String) && Pathname(db).exist?

          case db
          when DBI::DatabaseHandle
            [db, :dbi]
          when ::ActiveRecord::ConnectionAdapters::AbstractAdapter
            [db, :activerecord]
          else
            raise ArgumentError, "Unknown database adapter type #{db.class}"
          end
        end

        def attempt_sqlite3_connection(db)
          DBI.connect("DBI:SQLite3:#{db}")
        rescue SQLite3::NotADatabaseException
          raise ArgumentError, "Expected #{db} to point to a SQLite3 database"
        rescue NameError
          raise NameError, "In order to establish a connection to #{db}, please require 'dbi'"
        end
      end
    end
  end
end

require 'daru/io/link'
Daru::DataFrame.register_io_module :from_sql, Daru::IO::Importers::SQL
