RSpec.describe Daru::IO::Importers::Excel do
  context 'loads from excel spreadsheet' do
    subject    { described_class.new.read(path)     }

    let(:path) { 'spec/fixtures/excel/test_xls.xls' }

    it_behaves_like 'exact daru dataframe',
      ncols: 5,
      nrows: 6,
      order: %i[id name age city a1],
      data: [
        (1..6).to_a,
        %w[Alex Claude Peter Franz George Fernand],
        [20, 23, 25, nil, 5.5, nil],
        ['New York', 'London', 'London', 'Paris', 'Tome', nil],
        ['a,b', 'b,c', 'a', nil, 'a,b,c', nil]
      ],
      :'age.to_a.last' => nil
  end
end
