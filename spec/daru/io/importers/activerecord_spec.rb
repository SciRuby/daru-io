RSpec.describe Daru::IO::Importers::Activerecord do
  include_context 'sqlite3 database setup'
  context 'without specifying field names' do
    it_behaves_like 'activerecord importer', [:id, :name, :age], [[1,2],['Homer', 'Marge'],[20, 30]]
    its('id.to_a.first') { is_expected.to eq(1) }
  end

  context 'with specifying field names in parameters' do
    let(:fields) { [:name, :age] }

    it_behaves_like 'activerecord importer', [:name, :age], [['Homer', 'Marge'],[20, 30]]
  end
end
