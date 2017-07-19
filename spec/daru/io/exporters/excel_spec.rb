RSpec.describe Daru::IO::Exporters::Excel do
  include_context 'exporter setup'

  subject do
    Daru::DataFrame.rows(
      Spreadsheet.open(tempfile.path).worksheet(0).rows[1..-1].map(&:to_a),
      order: Spreadsheet.open(tempfile.path).worksheet(0).rows[0].to_a
    )
  end

  let(:filename) { 'test_write.xls' }
  let(:content)  { Spreadsheet.open tempfile.path }

  before { described_class.new(df, tempfile.path, opts).call }

  context 'writes to excel spreadsheet' do
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
end
