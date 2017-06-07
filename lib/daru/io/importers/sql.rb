require 'daru/io/importers/linkages/sql'

module Daru
  module IO
    module Importers
      class SQL
        def initialize(dbh, query)
          @dbh = dbh
          @query = query
        end

        # Execute a query and create a data frame from the result
        #
        # @param dbh [DBI::DatabaseHandle, String] A DBI connection OR Path to a SQlite3 database.
        # @param query [String] The query to be executed
        #
        # @return A dataframe containing the data resulting from the query
        def load
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
