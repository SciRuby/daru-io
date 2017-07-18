RSpec.describe Daru::IO::Exporters::JSON do
  include_context 'exporter setup'
  let(:df) do
    Daru::DataFrame.new(
      [
        {name: 'Jon Snow', age: 18, sex: 'Male'},
        {name: 'Rhaegar Targaryen', age: 54, sex: 'Male'},
        {name: 'Lyanna Stark', age: 36, sex: 'Female'}
      ],
      order: %i[name age sex],
      index: %i[child dad mom]
    )
  end

  let(:orient)   { :records    }
  let(:pretty)   { true        }
  let(:filename) { 'test.json' }
  subject        { JSON.parse(File.read(tempfile.path)) }

  before { described_class.new(df, tempfile.path, orient: orient, pretty: pretty, **opts).call }

  context 'writes DataFrame with default jsonpath options' do
    let(:opts) { {} }

    it { is_expected.to be_an(Array).and all be_a(Hash) }
    its('first.keys') { is_expected.to match_array(%w[name age sex]) }
    its(:count) { is_expected.to eq(3) }
  end

  context 'writes DataFrame with nested jsonpath options' do
    let(:opts) { {name: '$..person..name', age: '$..person..age', sex: '$..gender'} }

    it { is_expected.to be_an(Array).and all be_a(Hash) }
    its(:first) do
      is_expected.to eq(
        'gender' => 'Male',
        'person' => {
          'age' => 18,
          'name' => 'Jon Snow'
        }
      )
    end
  end

  context 'writes DataFrame with dynamic jsonpath options' do
    let(:opts) { {age: '$..{index}..{name}..age', sex: '$..{index}..{name}..gender'} }

    it { is_expected.to be_an(Array).and all be_a(Hash) }
    its(:first) do
      is_expected.to eq(
        'child' => {
          'Jon Snow' => {
            'age' => 18,
            'gender' => 'Male'
          }
        }
      )
    end
  end

  context 'writes DataFrame with :records orientation' do
    let(:opts)   { {age: '$..{name}..age', sex: '$..{name}..gender'} }
    let(:orient) { :records                                          }

    it { is_expected.to be_an(Array).and all be_a(Hash) }
    its(:first) do
      is_expected.to eq(
        'Jon Snow' => {
          'age' => 18,
          'gender' => 'Male'
        }
      )
    end
  end

  context 'writes DataFrame with :split orientation' do
    let(:opts)   { {age: '$..{name}..age', sex: '$..{name}..gender'} }
    let(:orient) { :split                                            }

    it { is_expected.to be_a(Hash).and all be_an(Array) }
    it do
      is_expected.to eq(
        'vectors' =>  %w[name age sex],
        'index'   =>  %w[child dad mom],
        'data'    =>  [
          ['Jon Snow', 'Rhaegar Targaryen', 'Lyanna Stark'],
          [18, 54, 36],
          %w[Male Male Female]
        ]
      )
    end
  end

  context 'writes DataFrame with :values orientation' do
    let(:orient) { :values }

    it { is_expected.to be_an(Array).and all be_an(Array) }
    it do
      is_expected.to eq(
        [
          ['Jon Snow', 'Rhaegar Targaryen', 'Lyanna Stark'],
          [18, 54, 36],
          %w[Male Male Female]
        ]
      )
    end
  end
end
