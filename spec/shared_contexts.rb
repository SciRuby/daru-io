RSpec.shared_context 'sqlite3 database setup' do |type|
	module Daru::IO::Rspec
	  class Account < ActiveRecord::Base
	    self.table_name = 'accounts'
	  end
	end

  before do
    FileUtils.rm(db_name) if File.file?(db_name)
    SQLite3::Database.new(db_name).tap do |db|
      db.execute "create table accounts(id integer, name varchar, age integer, primary key(id))"
      db.execute "insert into accounts values(1, 'Homer', 20)"
      db.execute "insert into accounts values(2, 'Marge', 30)"
    end
    Daru::IO::Rspec::Account.establish_connection "sqlite3:#{db_name}"
  end

  let(:db_name)  { 'daru_test' }
  let(:relation) { Daru::IO::Rspec::Account.all }

  subject {
    if defined? fields
      Daru::IO::Importers::ActiveRecord.new(relation, *fields).load
    else
      Daru::IO::Importers::ActiveRecord.new(relation).load
    end      

  }

  after { FileUtils.rm(db_name) }
end

RSpec.shared_context 'exporter setup' do
  let(:tempfile) { Tempfile.new(filename) }
  let(:opts)     { {} }
  let(:df)       { 
    Daru::DataFrame.new({
      'a' => [1,2,3,4,5],
      'b' => [11,22,33,44,55],
      'c' => ['a', 'g', 4, 5,'addadf'],
      'd' => [nil, 23, 4,'a','ff']})
  }

  def convert input
    if input.to_i.to_s == input # Integer in string
      input.to_i
    elsif input.to_f.to_s == input # Float in string
      input.to_f
    elsif input == "nil" # nil in string
      nil
    else
      input # Just string
    end
  end
end
