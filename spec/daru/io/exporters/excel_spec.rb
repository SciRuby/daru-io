RSpec.describe Daru::IO::Exporters::Excel do
  include_context 'exporter setup'

  let(:filename) { 'test_write.xls' }
  let(:content)  { Spreadsheet.open(tempfile.path) }
  let(:opts)     { {header: {color: :blue}, data: {color: :red}, index: {color: :green}} }

  before { described_class.new(df, **opts).write(tempfile.path) }

  context 'writes to excel spreadsheet' do
    subject do
      Daru::DataFrame.rows(
        Spreadsheet.open(tempfile.path).worksheet(0).rows[1..-1].map(&:to_a),
        order: Spreadsheet.open(tempfile.path).worksheet(0).rows[0].to_a
      )
    end

    let(:opts) { {index: false} }

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

  context 'writes to excel spreadsheet with header formatting' do
    subject { Spreadsheet.open(tempfile.path).worksheet(0).rows[0].format(0).font.color }

    it { is_expected.to eq(:blue) }
  end

  context 'writes to excel spreadsheet with index formatting' do
    subject { Spreadsheet.open(tempfile.path).worksheet(0).rows[1].format(0).font.color }

    it { is_expected.to eq(:green) }
  end

  context 'writes to excel spreadsheet with data formatting' do
    subject { Spreadsheet.open(tempfile.path).worksheet(0).rows[1].format(1).font.color }

    it { is_expected.to eq(:red) }
  end

  context 'writes to excel spreadsheet with multi-index' do
    subject { Spreadsheet.open(tempfile.path).worksheet(0).rows }

    let(:df) do
      Daru::DataFrame.new(
        [[1,2],[3,4]],
        order: %i[x y],
        index: [%i[a b c], %i[d e f]]
      )
    end

    it { is_expected.to eq([[' ', ' ', ' ', 'x', 'y'], ['a', 'b', 'c', 1, 3], ['d', 'e', 'f', 2, 4]]) }
  end
end
