RSpec.describe Daru::IO::Exporters::CSV do
  include_context 'csv exporter setup'
  context 'writes DataFrame to a CSV file' do
    let(:opts) { {} }
    subject { Daru::IO::Importers::CSV.load tempfile.path }

    it { is_expected.to be_an(Daru::DataFrame) }
    it { is_expected.to eq(df) }
  end

  context 'writes headers unless headers=false' do
    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.vectors.to_a) }
  end

  context 'does not write headers when headers=false' do
    let(:headers) { false }
    let(:opts)    { { headers: headers } }
    
    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.head(1).map { |v| (v.first || '').to_s }) }
  end
end
