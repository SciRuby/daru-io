RSpec.shared_examples 'a daru dataframe' do |name: nil, nrows: nil, ncols: nil, **opts|
  it            { is_expected.to be_a(Daru::DataFrame) }

  its(:name)    { is_expected.to eq(name)           } if name
  its(:ncols)   { is_expected.to eq(ncols)          } if ncols
  its(:nrows)   { is_expected.to eq(nrows)          } if nrows

  opts.each { |key, value| its(key.to_sym) { is_expected.to eq(value) } }
end

RSpec.shared_examples 'exact daru dataframe' do |dataframe: nil, data: nil, nrows: nil, ncols: nil, order: nil, index: nil, name: nil, **opts| # rubocop:disable Metrics/LineLength
  it_behaves_like 'a daru dataframe',
    name: name,
    nrows: nrows,
    ncols: ncols,
    **opts

  it            { is_expected.to eq(dataframe)      } if dataframe
  its(:data)    { is_expected.to ordered_data(data) } if data
  its(:index)   { is_expected.to eq(index.to_index) } if index
  its(:vectors) { is_expected.to eq(order.to_index) } if order
end

RSpec.shared_examples 'importer with json-path option' do
  context 'in temperature data' do
    let(:path) { 'spec/fixtures/json/temp.json' }

    context 'with only jsonpath columns' do
      let(:columns) { %w[value anomaly].map { |x| '$..data..'+x } }

      it_behaves_like 'exact daru dataframe',
        ncols: 2,
        nrows: 122,
        order: (0..1).to_a
    end

    context 'with only jsonpath named columns' do
      let(:named_columns) { {Anom: '$..data..anomaly', Val: '$..data..value'} }

      it_behaves_like 'exact daru dataframe',
        ncols: 2,
        nrows: 122,
        order: %i[Anom Val]
    end

    context 'with both jsonpath columns and named columns' do
      let(:columns)       { %w[$..data..anomaly]    }
      let(:named_columns) { {Val: '$..data..value'} }

      it_behaves_like 'exact daru dataframe',
        ncols: 2,
        nrows: 122,
        order: [0, :Val]
    end
  end

  context 'in tv series data' do
    let(:path) { 'spec/fixtures/json/got.json' }

    context 'with jsonpath columns' do
      let(:columns) do
        %w[name season number runtime]
          .map { |x| '$.._embedded..episodes..' + x }
      end

      it_behaves_like 'exact daru dataframe',
        ncols: 4,
        nrows: 61,
        order: (0..3).to_a
    end

    context 'with jsonpath named columns' do
      let(:named_columns) do
        {
          Name: '$.._embedded..episodes..name',
          Season: '$.._embedded..episodes..season',
          Number: '$.._embedded..episodes..number',
          Runtime: '$.._embedded..episodes..runtime'
        }
      end

      it_behaves_like 'exact daru dataframe',
        ncols: 4,
        nrows: 61,
        order: %i[Name Season Number Runtime]
    end

    context 'with jsonpath columns' do
      let(:columns) { %w[$.._embedded..episodes..name $.._embedded..episodes..season] }
      let(:named_columns) do
        {
          Number: '$.._embedded..episodes..number',
          Runtime: '$.._embedded..episodes..runtime'
        }
      end

      it_behaves_like 'exact daru dataframe',
        ncols: 4,
        nrows: 61,
        order: [0, 1, :Number, :Runtime]
    end
  end

  context 'on allsets data' do
    let(:path) { 'spec/fixtures/json/allsets.json' }

    context 'with jsonpath columns' do
      let(:columns) { %w[artist cmc mciNumber].map { |x| '$..LEA..cards..' + x } }
      let(:index)   { '$..LEA..cards..multiverseid'                              }

      it_behaves_like 'exact daru dataframe',
        ncols: 3,
        nrows: 18,
        order: (0..2).to_a,
        index: [94, 95, 96, 48, 232, 1, 233, 140, 49, 279, 234, 2, 280, 235, 141, 142, 50, 3]
    end
  end

  context 'on VAT data' do
    let(:path) { 'spec/fixtures/json/jsonvat.json' }

    context 'with jsonpath columns' do
      let(:columns) { %w[name periods].map { |x| '$..rates..'+x } }
      let(:index)   { '$..rates..code'                            }

      it_behaves_like 'exact daru dataframe',
        ncols: 2,
        nrows: 28,
        order: [0, 1],
        index: %w[DE PL HU SI SK PT FR DK RO UK SE HR FI NL LU BE ES LT EL LV CZ MT IT AT EE BG CY IE]
    end
  end
end
