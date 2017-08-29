require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # SQL Importer Class, that extends `from_sql` and `read_sql` methods to `Daru::DataFrame`
      class SQL < Base
        Daru::DataFrame.register_io_module :from_sql, self
        Daru::DataFrame.register_io_module :read_sql, self

        # Initializes a SQL Importer instance
        #
        # @param query [String] The query to be executed
        #
        # @example Initializing with a SQL query
        #   instance = Daru::IO::Importers::SQL.new("SELECT * FROM test")
        def initialize(query)
          optional_gem 'dbd-sqlite3', requires: 'dbd/SQLite3'
          optional_gem 'activerecord', '~> 4.0', requires: 'active_record'
          optional_gem 'dbi'
          optional_gem 'sqlite3'

          @query = query
        end

        # Imports a `Daru::DataFrame` from a SQL Importer instance
        #
        # @param dbh [DBI::DatabaseHandle] A DBI connection.
        #
        # @return [Daru::DataFrame]
        #
        # @example Importing from a DBI connection
        #   df = instance.from(DBI.connect("DBI:Mysql:database:localhost", "user", "password"))
        #
        #   #=> #<Daru::DataFrame(2x3)>
        #   #      id  name   age
        #   # 0     1 Homer    20
        #   # 1     2 Marge    30
        def from(dbh)
          @conn, @adapter = choose_adapter(dbh, @query)
          df_hash         = result_hash
          Daru::DataFrame.new(df_hash).tap(&:update)
        end

        # Imports a `Daru::DataFrame` from a SQL Importer instance and sqlite.db file
        #
        # @param path [String] Path to a SQlite3 database file.
        #
        # @return [Daru::DataFrame]
        #
        # @example Importing from a sqlite.db file
        #   df = instance.read('path/to/sqlite.db')
        #
        #   #=> #<Daru::DataFrame(2x3)>
        #   #      id  name   age
        #   # 0     1 Homer    20
        #   # 1     2 Marge    30
        def read(path)
          db = attempt_sqlite3_connection(path) if Pathname(path).exist?
          from(db)
        end

        private

        def attempt_sqlite3_connection(db)
          DBI.connect("DBI:SQLite3:#{db}")
        rescue SQLite3::NotADatabaseException
          raise ArgumentError, "Expected #{db} to point to a SQLite3 database"
        end

        def choose_adapter(db, query)
          query = String.try_convert(query) or
            raise ArgumentError, "Query must be a string, #{query.class} received"

          case db
          when DBI::DatabaseHandle
            [db, :dbi]
          when ::ActiveRecord::ConnectionAdapters::AbstractAdapter
            [db, :activerecord]
          else
            raise ArgumentError, "Unknown database adapter type #{db.class}"
          end
        end

        def column_names
          case @adapter
          when :dbi
            result.column_names
          when :activerecord
            result.columns
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

        def result_hash
          column_names
            .map(&:to_sym)
            .zip(rows.transpose)
            .to_h
        end

        def rows
          case @adapter
          when :dbi
            result.to_a.map(&:to_a)
          when :activerecord
            result.cast_values
          end
        end
      end
    end
  end
end
