RSpec.describe Daru::IO::Importers::Activerecord do
  include_context 'sqlite3 database setup'
  context 'without specifying field names' do
  	let(:order) { [:id, :name, :age] }
  	let(:data)	{ [[1,2],['Homer', 'Marge'],[20, 30]] }
    it_behaves_like 'sql activerecord importer'
    its('id.to_a.first') { is_expected.to eq(1) }
  end

  context 'with specifying field names in parameters' do
    let(:fields) { [:name, :age] }
    let(:order)	 { fields }
    let(:data) 	 { [['Homer', 'Marge'],[20, 30]] }
    it_behaves_like 'sql activerecord importer' 
  end
end
