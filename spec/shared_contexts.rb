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
      Daru::IO::Importers::ActiveRecord.load relation, *fields
    else
      Daru::IO::Importers::ActiveRecord.load relation
    end      

  }

  after { FileUtils.rm(db_name) }
end

RSpec.shared_context 'csv exporter setup' do
  before { Daru::IO::Exporters::CSV.write df, tempfile.path, opts }

  let(:tempfile) { Tempfile.new('data.csv') }
  let(:opts)     { {} }
  let(:df)       { 
    Daru::DataFrame.new({
      'a' => [1,2,3,4,5],
      'b' => [11,22,33,44,55],
      'c' => ['a', 'g', 4, 5,'addadf'],
      'd' => [nil, 23, 4,'a','ff']})
  }

  subject { File.open(tempfile.path, &:readline).chomp.split(',', -1) }
end

RSpec.shared_context 'excel exporter setup' do
  before { Daru::IO::Exporters::Excel.new(df, tempfile.path).write }

  let(:a)        { Daru::Vector.new(100.times.map { rand(100) }) }
  let(:b)        { Daru::Vector.new((['b'] * 100)) }
  let(:df)       { Daru::DataFrame.new({ :b => b, :a => a }) }
  let(:tempfile) { Tempfile.new('test_write.xls') }
  subject        { Daru::IO::Importers::Excel.load tempfile.path }
end

RSpec.shared_context 'csv importer setup' do
  before do
    %w[matrix_test repeated_fields scientific_notation sales-funnel].each do |file|
      WebMock
        .stub_request(:get,"http://dummy-remote-url/#{file}.csv")
        .to_return(status: 200, body: File.read("spec/fixtures/csv/#{file}.csv"))
      WebMock.disable_net_connect!(allow: %r{dummy-remote-url})
    end
  end

  let(:path) { 'spec/fixtures/csv/matrix_test.csv' }
  let(:opts) { { col_sep: ' ', headers: true } }
  subject    { Daru::IO::Importers::CSV.load(path, opts) }
end
