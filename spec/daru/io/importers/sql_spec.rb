module Daru::IO::Rspec
  class Account < ActiveRecord::Base
    self.table_name = 'accounts'
  end
end

RSpec.describe Daru::IO::Importers::SQL do
  let(:db_name) { 'daru_test' }
  let(:relation) { Daru::IO::Rspec::Account.all }

  before do
    FileUtils.rm(db_name) if File.file?(db_name)
    SQLite3::Database.new(db_name).tap do |db|
      db.execute "create table accounts(id integer, name varchar, age integer, primary key(id))"
      db.execute "insert into accounts values(1, 'Homer', 20)"
      db.execute "insert into accounts values(2, 'Marge', 30)"
    end
    Daru::IO::Rspec::Account.establish_connection "sqlite3:#{db_name}"
  end

  after do
    FileUtils.rm(db_name)
  end

  context 'with a database handler of DBI' do
    let(:db) { DBI.connect("DBI:SQLite3:#{db_name}") }
    subject { Daru::IO::Importers::SQL.load(db, "select * from accounts") }

    it { is_expected.to be_an(Daru::DataFrame) }
    its(:nrows) { is_expected.to eq(2) }
    its('vectors.to_a') { is_expected.to eq([:age, :id, :name]) }
    it { is_expected.to eq(Daru::DataFrame.new([[20,30],[1,2],['Homer', 'Marge']],order: [:age, :id, :name])) }
  end

  context 'with a database connection of ActiveRecord' do
    let(:connection) do
      Daru::IO::Rspec::Account.establish_connection "sqlite3:#{db_name}"
      Daru::IO::Rspec::Account.connection
    end
    subject { Daru::IO::Importers::SQL.load(connection, "select * from accounts") }

    it { is_expected.to be_an(Daru::DataFrame) }
    its(:nrows) { is_expected.to eq(2) }
    its('vectors.to_a') { is_expected.to eq([:age, :id, :name]) }
    it { is_expected.to eq(Daru::DataFrame.new([[20,30],[1,2],['Homer', 'Marge']],order: [:age, :id, :name])) }
  end
end

RSpec.describe Daru::IO::Importers::SQLHelper do
  let(:db_name) { 'daru_test' }
  let(:relation) { Daru::IO::Rspec::Account.all }
  let(:query) { 'select * from accounts' }
  let(:source) do
    ActiveRecord::Base.establish_connection("sqlite3:#{db_name}")
    ActiveRecord::Base.connection
  end
  subject(:df) { Daru::IO::Importers::SQL.load(source, query) }

  before do
    FileUtils.rm(db_name) if File.file?(db_name)
    SQLite3::Database.new(db_name).tap do |db|
      db.execute "create table accounts(id integer, name varchar, age integer, primary key(id))"
      db.execute "insert into accounts values(1, 'Homer', 20)"
      db.execute "insert into accounts values(2, 'Marge', 30)"
    end
    Daru::IO::Rspec::Account.establish_connection "sqlite3:#{db_name}"
  end

  after do
    FileUtils.rm(db_name)
  end

  context 'with DBI::DatabaseHandle' do
    let(:source) { DBI.connect("DBI:SQLite3:#{db_name}") }
    it { is_expected.to be_a(Daru::DataFrame) }
    it { expect(df.row[0]).to have_attributes(id: 1, age: 20) }
    its(:nrows) { is_expected.to eq 2 }
  end

  context 'with ActiveRecord::Connection' do
    it { is_expected.to be_a(Daru::DataFrame) }
    it { expect(df.row[0]).to have_attributes(id: 1, age: 20) }
    its(:nrows) { is_expected.to eq 2 }
  end

  context 'with path to sqlite3 file' do
    let(:source) { db_name }
    it { is_expected.to be_a(Daru::DataFrame) }
    it { expect(df.row[0]).to have_attributes(id: 1, age: 20) }
    its(:nrows) { is_expected.to eq 2 }
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
    let(:source) { 'spec/fixtures/bank2.dat' }
    it { expect { df }.to raise_error(ArgumentError) }
  end
end