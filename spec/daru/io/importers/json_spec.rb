RSpec.describe Daru::IO::Importers::JSON do
  subject { described_class.new(*columns, order: order, index: index, **named_columns).read(path) }

  let(:path)          { ''  }
  let(:index)         { nil }
  let(:order)         { nil }
  let(:columns)       { nil }
  let(:named_columns) { {}  }

  context 'on simple json file' do
    context 'in NASA data' do
      let(:path) { 'spec/fixtures/json/nasadata.json' }

      context 'without xpath (simple json)' do
        it_behaves_like 'exact daru dataframe',
          ncols: 10,
          nrows: 202,
          order: %w[designation discovery_date h_mag i_deg moid_au orbit_class period_yr pha q_au_1 q_au_2]
      end
    end
  end

  it_behaves_like 'importer with json-path option'

  context 'parses json response' do
    subject { described_class.new(*columns, order: order, index: index, **named_columns).from(instance) }

    let(:instance) { ::JSON.parse(File.read('spec/fixtures/json/nasadata.json')) }

    it_behaves_like 'exact daru dataframe',
      ncols: 10,
      nrows: 202,
      order: %w[designation discovery_date h_mag i_deg moid_au orbit_class period_yr pha q_au_1 q_au_2]
  end

  context 'parses json string' do
    subject { described_class.new(*columns, order: order, index: index, **named_columns).from(instance) }

    let(:instance) { File.read('spec/fixtures/json/nasadata.json') }

    it_behaves_like 'exact daru dataframe',
      ncols: 10,
      nrows: 202,
      order: %w[designation discovery_date h_mag i_deg moid_au orbit_class period_yr pha q_au_1 q_au_2]
  end

  context 'parses remote and local file similarly' do
    let(:local_path) { 'spec/fixtures/json/nasadata.json'      }
    let(:path)       { 'http://dummy-remote-url/nasadata.json' }

    before do
      WebMock
        .stub_request(:get, path)
        .to_return(status: 200, body: File.read(local_path))
      WebMock.disable_net_connect!(allow: /dummy-remote-url/)
    end

    it_behaves_like 'exact daru dataframe',
      ncols: 10,
      nrows: 202,
      order: %w[designation discovery_date h_mag i_deg moid_au orbit_class period_yr pha q_au_1 q_au_2]
  end

  context 'raises error for invalid argument' do # rubocop:disable RSpec/EmptyExampleGroup
    context 'json input is invalid' do # rubocop:disable RSpec/EmptyExampleGroup
      let(:order)         { %i[a b] }
      let(:named_columns) { {x: 1, y: 2} }

      its_call { is_expected.to raise_error(ArgumentError) }
    end
  end
end
