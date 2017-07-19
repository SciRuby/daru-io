RSpec.describe Daru::IO::Importers::Plaintext do
  subject { described_class.new(path, vectors).call }

  let(:vectors) { %i[v1 v2 v3] }

  context 'reads data from plain text files' do
    let(:path)    { 'spec/fixtures/plaintext/bank2.dat' }
    let(:vectors) { %i[v1 v2 v3 v4 v5 v6] }

    it_behaves_like 'exact daru dataframe',
      ncols: 6,
      nrows: 200,
      order: %i[v1 v2 v3 v4 v5 v6]
  end

  context 'understands empty fields', skip: 'See FIXME note at importers/plainext.rb#L33-L36' do
    let(:path) { 'spec/fixtures/plaintext/empties.dat' }

    it_behaves_like 'exact daru dataframe',
      ncols: 5,
      nrows: 6,
      :'row[1].to_a' => [4, nil, 6]
  end

  context 'understands non-numeric fields' do
    let(:path) { 'spec/fixtures/plaintext/strings.dat' }

    it_behaves_like 'exact daru dataframe',
      ncols: 3,
      nrows: 2,
      :'v1.to_a' => %w[test foo]
  end
end
