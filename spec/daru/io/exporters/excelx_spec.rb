RSpec.describe Daru::IO::Exporters::Excelx do
  include_context 'exporter setup'

  let(:filename) { ['test_write', '.xlsx'] }
  let(:content)  { Roo::Excelx.new(tempfile.path).sheet('Sheet0').to_a }

  before { described_class.new(df, **opts).write(tempfile.path) }

  context 'writes to excelx worksheet without index' do
    subject { Daru::DataFrame.rows(content[1..-1].map { |x| x.map { |y| convert(y) } }, order: content[0]) }

    let(:opts) { {index: false} }

    it_behaves_like 'exact daru dataframe',
      ncols: 4,
      nrows: 5,
      order: %w[a b c d],
      data: [
        [1,2,3,4,5],
        [11,22,33,44,55],
        ['a', 'g', 4, 5,'addadf'],
        ['', 23, 4,'a','ff']
      ]
  end

  context 'writes to excelx worksheet with multi-index' do
    subject { content.map { |x| x.map { |y| convert(y) } } }

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
