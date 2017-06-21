RSpec.describe Daru::IO::Importers::ActiveRecord do
  include_context 'sqlite3 database setup'
  context 'without specifying field names' do
    let(:order)  { %I[id name age] }
    let(:fields) { [] }
    let(:data)   { [[1,2],%w[Homer Marge],[20, 30]] }

    it_behaves_like 'sql activerecord importer'
    its('id.to_a.first') { is_expected.to eq(1) }
  end

  context 'with specifying field names in parameters' do
    let(:fields) { %I[name age] }
    let(:order)	 { fields }
    let(:data) 	 { [%w[Homer Marge],[20, 30]] }

    it_behaves_like 'sql activerecord importer'
  end
end
