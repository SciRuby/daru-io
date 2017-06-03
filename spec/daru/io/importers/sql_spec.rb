RSpec.describe Daru::IO::Importers::SQL do
  include_context 'sqlite3 database setup'
  context 'with a database handler of DBI' do
    let(:db) { DBI.connect("DBI:SQLite3:#{db_name}") }
    subject { Daru::IO::Importers::SQL.load(db, "select * from accounts") }

    it_behaves_like 'activerecord importer', [:age, :id, :name], [[20, 30],[1,2],['Homer', 'Marge']]
  end

  context 'with a database connection of ActiveRecord' do
    let(:connection) do
      Daru::IO::Rspec::Account.establish_connection "sqlite3:#{db_name}"
      Daru::IO::Rspec::Account.connection
    end
    subject { Daru::IO::Importers::SQL.load(connection, "select * from accounts") }

    it_behaves_like 'activerecord importer', [:age, :id, :name], [[20, 30],[1,2],['Homer', 'Marge']]
  end
end

RSpec.describe Daru::IO::Importers::SQLHelper do
  include_context 'sqlite3 database setup'
  let(:query) { 'select * from accounts' }
  let(:source) do
    ActiveRecord::Base.establish_connection("sqlite3:#{db_name}")
    ActiveRecord::Base.connection
  end
  subject(:df) { Daru::IO::Importers::SQL.load(source, query) }

  context 'with DBI::DatabaseHandle' do
    let(:source) { DBI.connect("DBI:SQLite3:#{db_name}") }
    it_behaves_like 'sql importer'
  end

  context 'with ActiveRecord::Connection' do
    it_behaves_like 'sql importer'
  end

  context 'with path to sqlite3 file' do
    let(:source) { db_name }
    it_behaves_like 'sql importer'
  end

  context 'with an object not a string as a query' do
    let(:query) { Object.new }
    it { expect { df }.to raise_error(ArgumentError) }
  end

  context 'with an object not a database connection' do
    let(:source) { Object.new }
    it { expect { df }.to raise_error(ArgumentError) }
  end

  context 'with path to unsupported db file' do
    let(:source) { 'spec/fixtures/plaintext/bank2.dat' }
    it { expect { df }.to raise_error(ArgumentError) }
  end
end