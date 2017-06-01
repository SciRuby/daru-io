require 'sqlite3'
require 'dbi'
require 'active_record'

module Daru::IO::Rspec
  class Account < ActiveRecord::Base
    self.table_name = 'accounts'
  end
end

RSpec.describe Daru::IO::Importers::Activerecord do
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

  context 'without specifying field names' do
    subject { Daru::IO::Importers::Activerecord.load relation }

    it { is_expected.to be_an(Daru::DataFrame) }
    its(:nrows) { is_expected.to eq(2) }
    its('vectors.to_a') { is_expected.to eq([:id, :name, :age]) }
    its('id.to_a.first') { is_expected.to eq(1) }
    it { is_expected.to eq(Daru::DataFrame.new([[1,2],['Homer', 'Marge'],[20, 30]],order: [:id, :name, :age])) }
  end

  context 'with specifying field names in parameters' do
    subject { Daru::IO::Importers::Activerecord.load(relation, :name, :age) }

    it { is_expected.to be_an(Daru::DataFrame) }
    its(:nrows) { is_expected.to eq(2) }
    its('vectors.to_a') { is_expected.to eq([:name, :age]) }
    it { is_expected.to eq(Daru::DataFrame.new([['Homer', 'Marge'],[20, 30]],order: [:name, :age])) }
  end
end
