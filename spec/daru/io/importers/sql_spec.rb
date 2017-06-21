RSpec.describe Daru::IO::Importers::SQL do
  include_context 'sqlite3 database setup'

  subject(:df) { described_class.new(source, query).call }

  let(:query)  { 'select * from accounts'         }
  let(:order)  { %i[age id name]                  }
  let(:data)   { [[20, 30],[1,2],%w[Homer Marge]] }
  let(:source) { ActiveRecord::Base.connection    }

  context 'with a database handler of DBI' do
    subject { described_class.new(db, query).call }

    let(:db) { DBI.connect("DBI:SQLite3:#{db_name}") }

    it_behaves_like 'sql activerecord importer'
  end

  context 'with a database connection of ActiveRecord' do
    subject { described_class.new(connection, query).call }

    let(:connection) { Daru::IO::Rspec::Account.connection }

    before { Daru::IO::Rspec::Account.establish_connection "sqlite3:#{db_name}" }

    it_behaves_like 'sql activerecord importer'
  end

  before { ActiveRecord::Base.establish_connection("sqlite3:#{db_name}") }

  context 'with DBI::DatabaseHandle' do
    let(:source) { DBI.connect("DBI:SQLite3:#{db_name}") }

    it_behaves_like 'sql helper importer'
  end

  context 'with ActiveRecord::Connection' do
    it_behaves_like 'sql helper importer'
  end

  context 'with path to sqlite3 file' do
    let(:source) { db_name }

    it_behaves_like 'sql helper importer'
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
