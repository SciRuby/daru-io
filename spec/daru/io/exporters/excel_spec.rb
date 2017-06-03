RSpec.describe Daru::IO::Exporters::Excel do
  include_context 'excel exporter setup'
  context 'writes to excel spreadsheet' do
    it_behaves_like 'daru dataframe'
    it { is_expected.to eq(df) }
  end
end
