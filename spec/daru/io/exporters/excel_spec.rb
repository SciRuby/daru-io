RSpec.describe Daru::IO::Exporters::Excel do
  include_context 'excel exporter setup'
  context "writes to excel spreadsheet" do
    it { is_expected.to be_an(Daru::DataFrame) }
    it { is_expected.to eq(df) }
  end
end
