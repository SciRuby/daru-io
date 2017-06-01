require 'sqlite3'
require 'dbi'
require 'active_record'

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
