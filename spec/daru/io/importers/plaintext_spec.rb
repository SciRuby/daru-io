RSpec.describe Daru::IO::Importers::Plaintext do
  let(:vectors) { [:v1,:v2,:v3] }
  subject { Daru::IO::Importers::Plaintext.new(path, vectors).load }

  context 'reads data from plain text files' do
    let(:path)    { 'spec/fixtures/plaintext/bank2.dat' }
    let(:vectors) { [:v1,:v2,:v3,:v4,:v5,:v6] }

    it_behaves_like 'daru dataframe'
    its('vectors.to_a') { is_expected.to eq([:v1,:v2,:v3,:v4,:v5,:v6]) }
  end

  context 'understands empty fields', :skip => 'See FIXME note at importers/plainext.rb#L33-L36' do
    let(:path) { 'spec/fixtures/plaintext/empties.dat' }

    it_behaves_like 'daru dataframe'
    its('row[1].to_a') { is_expected.to eq([4, nil, 6]) }
  end

  context 'understands non-numeric fields' do
    let(:path) { 'spec/fixtures/plaintext/strings.dat' }

    it_behaves_like 'daru dataframe'
    its('v1.to_a') { is_expected.to eq(['test', 'foo']) }
  end
end
