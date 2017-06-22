require 'daru/io/exporters/base'

module Daru
  module IO
    module Exporters
      class SQL < Base
        # Exports +Daru::DataFrame+ to an SQL table.
        #
        # @param dataframe [Daru::DataFrame] A dataframe to export.
        # @param dbh [DBI] A DBI database connection object.
        # @param table [String] The SQL table to export to.
        #
        # @example Writing to an SQL Table with database credentials
        #   df = Daru::DataFrame.new([[1,2],[3,4]], order: [:a, :b])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      a   b
        #   #  0   1   3
        #   #  1   2   4
        #
        #   table = 'test'
        #
        #   dbh = DBI.connect("DBI:Mysql:database:localhost", "user", "password")
        #   # Enter the actual SQL database credentials in the above line
        #
        #   Daru::IO::Exporters::SQL.new(df, dbh, table).call
        def initialize(dataframe, dbh, table)
          super(dataframe)
          @dbh       = dbh
          @table     = table
        end

        def call
          optional_gem 'dbd-sqlite3', requires: 'dbd/SQLite3'
          optional_gem 'dbi'
          optional_gem 'sqlite3'

          query = "INSERT INTO #{@table} (#{@dataframe.vectors.to_a.join(',')}"\
                  ") VALUES (#{(['?']*@dataframe.vectors.size).join(',')})"
          sth   = @dbh.prepare(query)
          @dataframe.each_row { |c| sth.execute(*c.to_a) }
          true
        end
      end
    end
  end
end

require 'daru/io/link'
Daru::DataFrame.register_io_module :to_sql, Daru::IO::Exporters::SQL
