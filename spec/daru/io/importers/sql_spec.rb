RSpec.describe Daru::IO::Importers::SQL do
  include_context 'sqlite3 database setup'

  subject { described_class.from(source).call(query) }

  let(:query)  { 'select * from accounts'         }
  let(:source) { ActiveRecord::Base.connection    }

  context 'with a database handler of DBI' do
    subject { described_class.from(db).call(query) }

    let(:db) { DBI.connect("DBI:SQLite3:#{db_name}") }

    it_behaves_like 'exact daru dataframe',
      ncols: 3,
      nrows: 2,
      order: %i[age id name],
      data: [[20, 30],[1,2],%w[Homer Marge]]
  end

  context 'with a database connection of ActiveRecord' do
    subject { described_class.from(connection).call(query) }

    let(:connection) { Daru::IO::Rspec::Account.connection }

    before { Daru::IO::Rspec::Account.establish_connection "sqlite3:#{db_name}" }

    it_behaves_like 'exact daru dataframe',
      ncols: 3,
      nrows: 2,
      order: %i[age id name],
      data: [[20, 30],[1,2],%w[Homer Marge]]
  end

  before { ActiveRecord::Base.establish_connection("sqlite3:#{db_name}") }

  context 'with DBI::DatabaseHandle' do
    let(:source) { DBI.connect("DBI:SQLite3:#{db_name}") }

    it_behaves_like 'exact daru dataframe',
      ncols: 3,
      nrows: 2,
      order: %i[age id name],
      data: [[20, 30],[1,2],%w[Homer Marge]]
  end

  context 'with ActiveRecord::Connection' do
    it_behaves_like 'exact daru dataframe',
      ncols: 3,
      nrows: 2,
      order: %i[age id name],
      data: [[20, 30],[1,2],%w[Homer Marge]]
  end

  context 'with path to sqlite3 file' do
    subject { described_class.read(source).call(query) }

    let(:source) { db_name }

    it_behaves_like 'exact daru dataframe',
      ncols: 3,
      nrows: 2,
      order: %i[age id name],
      data: [[20, 30],[1,2],%w[Homer Marge]]
  end

  context 'raises error for invalid arguments' do # rubocop:disable RSpec/EmptyExampleGroup
    let(:query)  { Object.new                          }
    let(:source) { 'spec/fixtures/plaintext/bank2.dat' }

    its_call { is_expected.to raise_error(ArgumentError) }
  end
end
