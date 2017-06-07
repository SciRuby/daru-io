RSpec.describe Daru::IO::Exporters::CSV do
  include_context 'exporter setup'
  let(:filename) { 'test.csv' }
  subject        { File.open(tempfile.path, &:readline).chomp.split(',', -1) }

  before { Daru::IO::Exporters::CSV.new(df, tempfile.path, opts).write }

  context 'writes DataFrame to a CSV file' do
    let(:opts) { {} }
    let(:content) { CSV.read(tempfile.path) }
    subject { Daru::DataFrame.rows content[1..-1].map { |x| x.map { |y| convert(y) } }, order: content[0] }

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
