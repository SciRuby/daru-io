RSpec.describe Daru::IO::Exporters::RDS do
  subject { Daru::DataFrame.new(RSRuby.instance.eval_R("readRDS('#{tempfile.path}')")) }

  include_context 'exporter setup'

  let(:variable) { 'test.dataframe' }
  let(:filename) { 'test.rds'       }

  before { described_class.new(df, tempfile.path, variable).call }

  context 'writes DataFrame to a RDS file' do
    it_behaves_like 'exact daru dataframe',
      ncols: 4,
      nrows: 5,
      order: %w[a b c d],
      data: [
        [1.0,2.0,3.0,4.0,5.0],
        [11.0,22.0,33.0,44.0,55.0],
        %w[a g 4 5 addadf],
        %w[NA 23 4 a ff]
      ]
  end
end
