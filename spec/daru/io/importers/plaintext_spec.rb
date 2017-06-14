RSpec.describe Daru::IO::Importers::Plaintext do
  let(:vectors) { %i[v1 v2 v3] }
  subject { described_class.new(path, vectors).call }

  context 'reads data from plain text files' do
    let(:path)    { 'spec/fixtures/plaintext/bank2.dat' }
    let(:vectors) { %i[v1 v2 v3 v4 v5 v6] }

    it_behaves_like 'daru dataframe'
    its('vectors.to_a') { is_expected.to eq(vectors) }
  end

  context 'understands empty fields', skip: 'See FIXME note at importers/plainext.rb#L33-L36' do
    let(:path) { 'spec/fixtures/plaintext/empties.dat' }

    it_behaves_like 'daru dataframe'
    its('row[1].to_a') { is_expected.to eq([4, nil, 6]) }
  end

  context 'understands non-numeric fields' do
    let(:path) { 'spec/fixtures/plaintext/strings.dat' }

    it_behaves_like 'daru dataframe'
    its('v1.to_a') { is_expected.to eq(%w[test foo]) }
  end
end
