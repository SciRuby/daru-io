RSpec.describe Daru::IO::Importers::SQL do # rubocop:disable Metrics/BlockLength
  include_context 'sqlite3 database setup'
  let(:query) { 'select * from accounts' }
  let(:order) { %i[age id name] }
  let(:data)  { [[20, 30],[1,2],%w[Homer Marge]] }

  context 'with a database handler of DBI' do
    let(:db) { DBI.connect("DBI:SQLite3:#{db_name}") }
    subject { described_class.new(db, query).load }

    it_behaves_like 'sql activerecord importer'
  end

  context 'with a database connection of ActiveRecord' do
    let(:connection) { Daru::IO::Rspec::Account.connection }
    subject { described_class.new(connection, query).load }

    before { Daru::IO::Rspec::Account.establish_connection "sqlite3:#{db_name}" }

    it_behaves_like 'sql activerecord importer'
  end

  let(:source) { ActiveRecord::Base.connection }
  subject(:df) { described_class.new(source, query).load }

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
