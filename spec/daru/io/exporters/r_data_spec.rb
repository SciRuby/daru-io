RSpec.describe Daru::IO::Exporters::RData do
  subject { Daru::DataFrame.new(instance.send(variables[0].to_sym)) }

  include_context 'exporter setup'

  let(:instance)  { RSRuby.instance                             }
  let(:filename)  { 'test.RData'                                }
  let(:variables) { instance.eval_R("load('#{tempfile.path}')") }

  before { described_class.new(tempfile.path, **opts).call }

  context 'writes DataFrame to a RData file' do
    let(:opts)    { {:'first.df' => df, :'last.df' => df} }

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
