RSpec.describe Daru::IO::Exporters::CSV do
  subject { File.open(tempfile.path, &:readline).chomp.split(',', -1) }

  include_context 'exporter setup'

  let(:filename) { 'test.csv' }

  before { described_class.new(df, tempfile.path, opts).call }

  context 'writes DataFrame to a CSV file' do
    subject { Daru::DataFrame.rows content[1..-1].map { |x| x.map { |y| convert(y) } }, order: content[0] }

    let(:opts) { {} }
    let(:content) { CSV.read(tempfile.path) }

    it_behaves_like 'daru dataframe'
    it { is_expected.to eq(df) }
  end

  context 'writes headers unless headers=false' do
    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.vectors.to_a) }
  end

  context 'does not write headers when headers=false' do
    let(:headers) { false }
    let(:opts)    { {headers: headers} }

    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.head(1).map { |v| (v.first || '').to_s }) }
  end
end
