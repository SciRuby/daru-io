require 'daru/io/importers/linkages/activerecord'

module Daru
  module IO
    module Importers
      module SQL
        class << self
          # Execute a query and create a data frame from the result
          #
          # @param dbh [DBI::DatabaseHandle, String] A DBI connection OR Path to a SQlite3 database.
          # @param query [String] The query to be executed
          #
          # @return A dataframe containing the data resulting from the query
          def load(dbh, query)
            conn, adapter = SQLHelper.choose_adapter dbh, query
            df_hash       = SQLHelper.result_hash(conn, query, adapter)
            Daru::DataFrame.new(df_hash).tap(&:update)
          end
        end
      end
      module SQLHelper
        class << self
          def set(conn, query, adapter)
            @conn = conn
            @query = query
            @adapter = adapter
          end

          def result_hash(conn, query, adapter)
            @conn = conn
            @query = query
            @adapter = adapter
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
              @result ||= result.to_a.map(&:to_a)
            when :activerecord
              @result ||= result.cast_values
            end
            @result
          end

          def result
            case @adapter
            when :dbi
              @conn.execute(@query)
            when :activeRecord
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
            when ActiveRecord::ConnectionAdapters::AbstractAdapter
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
end
