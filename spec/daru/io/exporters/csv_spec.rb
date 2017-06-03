RSpec.describe Daru::IO::Exporters::CSV do
  include_context 'csv exporter setup'
  context "writes DataFrame to a CSV file" do
    subject { Daru::IO::Importers::CSV.load tempfile.path }

    it { is_expected.to be_an(Daru::DataFrame) }
    it { is_expected.to eq(df) }
  end

  context "writes headers unless headers=false" do
    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.vectors.to_a) }
  end

  context "won't write headers when headers=false" do
    let(:headers) { false }
    before { Daru::IO::Exporters::CSV.write df, tempfile.path, headers: headers }

    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.head(1).map { |v| (v.first || '').to_s }) }
  end
end
