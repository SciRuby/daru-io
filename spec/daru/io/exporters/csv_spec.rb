RSpec.describe Daru::IO::Exporters::CSV do
  subject { File.open(tempfile.path, &:readline).chomp.split(',', -1) }

  include_context 'exporter setup'

  let(:filename) { 'test.csv' }

  before { described_class.new(df, tempfile.path, opts).call }

  context 'writes DataFrame to a CSV file' do
    subject { Daru::DataFrame.rows content[1..-1].map { |x| x.map { |y| convert(y) } }, order: content[0] }

    let(:opts) { {} }
    let(:content) { CSV.read(tempfile.path) }

    it_behaves_like 'exact daru dataframe',
      ncols: 4,
      nrows: 5,
      order: %w[a b c d],
      data: [
        [1,2,3,4,5],
        [11,22,33,44,55],
        ['a', 'g', 4, 5,'addadf'],
        [nil, 23, 4,'a','ff']
      ]
  end

  context 'writes headers unless headers=false' do
    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.vectors.to_a) }
  end

  context 'does not write headers when headers=false' do
    let(:headers) { false              }
    let(:opts)    { {headers: headers} }

    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.head(1).map { |v| (v.first || '').to_s }) }
  end

  context 'writes convert_comma only on float values' do
    subject { CSV.read(tempfile.path, col_sep: ';') }

    let(:df)      { Daru::DataFrame.new('a' => [1, 4.4, nil, 'Sr. Arthur']) }
    let(:opts)    { {convert_comma: true, col_sep: ';'} }

    it { is_expected.to eq([['a'], ['1'], ['4,4'], [''], ['Sr. Arthur']]) }
  end

  context 'writes into .csv.gz format' do
    subject        { Zlib::GzipReader.new(open(tempfile.path)).read.split("\n") }

    let(:opts)     { {compression: :gzip} }
    let(:filename) { 'test.csv.gz'        }

    it { is_expected.to be_an(Array).and all be_a(String) }
    it { is_expected.to eq(['a,b,c,d', '1,11,a,', '2,22,g,23', '3,33,4,4', '4,44,5,a', '5,55,addadf,ff']) }
  end

  context 'writes into .csv.gz format with only order' do
    subject        { Zlib::GzipReader.new(open(tempfile.path)).read.split("\n") }

    let(:df)       { Daru::DataFrame.new('a' => [], 'b' => [], 'c' => [], 'd' => []) }
    let(:opts)     { {compression: :gzip}                                            }
    let(:filename) { 'test.csv.gz'                                                   }

    it { is_expected.to be_an(Array).and all be_a(String) }
    it { is_expected.to eq(%w[a,b,c,d]) }
  end
end
