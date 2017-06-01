require 'sqlite3'
require 'dbi'
require 'active_record'

module Daru::IO::Rspec
  class Account < ActiveRecord::Base
    self.table_name = 'accounts'
  end
end

# shared_context 'with accounts table in sqlite3 database' do
#   let(:db_name) do
#     'daru_test'
#   end

#   before do
#     # just in case
#     FileUtils.rm(db_name) if File.file?(db_name)

#     SQLite3::Database.new(db_name).tap do |db|
#       db.execute "create table accounts(id integer, name varchar, age integer, primary key(id))"
#       db.execute "insert into accounts values(1, 'Homer', 20)"
#       db.execute "insert into accounts values(2, 'Marge', 30)"
#     end
#   end

#   after do
#     FileUtils.rm(db_name)
#   end
# end

RSpec.describe Daru::IO::Importers::Activerecord do
      let(:db_name) { 'daru_test' }

      before do
        # just in case
        FileUtils.rm(db_name) if File.file?(db_name)

        SQLite3::Database.new(db_name).tap do |db|
          db.execute "create table accounts(id integer, name varchar, age integer, primary key(id))"
          db.execute "insert into accounts values(1, 'Homer', 20)"
          db.execute "insert into accounts values(2, 'Marge', 30)"
        end
      end

      after do
        FileUtils.rm(db_name)
      end

      context 'with ActiveRecord::Relation' do
        before do
          Daru::IO::Rspec::Account.establish_connection "sqlite3:#{db_name}"
        end

        let(:relation) do
          Daru::IO::Rspec::Account.all
        end

        context 'without specifying field names' do
          subject do
            Daru::DataFrame.from_activerecord(relation)
          end

          it 'loads data from an AR::Relation object' do
            accounts = subject
            expect(accounts.class).to eq Daru::DataFrame
            expect(accounts.nrows).to eq 2
            expect(accounts.vectors.to_a).to eq [:id, :name, :age]
            expect(accounts.row[0][:id]).to eq 1
            expect(accounts.row[0][:name]).to eq 'Homer'
            expect(accounts.row[0][:age]).to eq 20
          end
        end

        context 'with specifying field names in parameters' do
          subject do
            Daru::DataFrame.from_activerecord(relation, :name, :age)
          end

          it 'loads data from an AR::Relation object' do
            accounts = subject
            expect(accounts.class).to eq Daru::DataFrame
            expect(accounts.nrows).to eq 2
            expect(accounts.vectors.to_a).to eq [:name, :age]
            expect(accounts.row[0][:name]).to eq 'Homer'
            expect(accounts.row[0][:age]).to eq 20
          end
        end
      end
    end
