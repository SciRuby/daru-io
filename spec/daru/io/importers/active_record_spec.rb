RSpec.describe Daru::IO::Importers::ActiveRecord do
  include_context 'sqlite3 database setup'
  context 'without specifying field names' do
    let(:fields) { [] }

    it_behaves_like 'exact daru dataframe',
      ncols: 3,
      nrows: 2,
      order: %i[id name age],
      data: [[1,2],%w[Homer Marge],[20, 30]]

    its('id.to_a.first') { is_expected.to eq(1) }
  end

  context 'with specifying field names in parameters' do
    let(:fields) { %I[name age] }

    it_behaves_like 'exact daru dataframe',
      ncols: 2,
      nrows: 2,
      order: %i[name age],
      data: [%w[Homer Marge],[20, 30]]
  end
end
