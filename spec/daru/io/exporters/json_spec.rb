RSpec.describe Daru::IO::Exporters::JSON do
  include_context 'exporter setup'

  subject { JSON.parse(File.read(tempfile.path)) }

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
  let(:pretty)   { true        }
  let(:filename) { 'test.json' }

  before { described_class.new(df, tempfile.path, pretty: pretty, **opts).call }

  context 'writes DataFrame with default jsonpath options' do
    let(:opts) { {} }

    it                { is_expected.to be_an(Array).and all be_a(Hash) }
    its(:count)       { is_expected.to eq(3)                           }
    its('first.keys') { is_expected.to match_array(%w[name age sex])   }
  end

  context 'writes DataFrame with nested jsonpath options' do
    let(:opts) { {name: '$.person.name', age: '$.person.age', sex: '$.gender', index: '$.relation'} }

    it { is_expected.to be_an(Array).and all be_a(Hash) }
    its(:first) do
      is_expected.to eq(
        'gender' => 'Male',
        'relation' => 'child',
        'person' => {'age' => 18, 'name' => 'Jon Snow'}
      )
    end
  end

  context 'writes DataFrame with dynamic jsonpath options' do
    let(:opts) { {age: '$.{index}.{name}.age', sex: '$.{index}.{name}.gender'} }

    it { is_expected.to be_an(Array).and all be_a(Hash) }
    its(:first) { is_expected.to eq('child' => {'Jon Snow' => {'age' => 18, 'gender' => 'Male'}}) }
  end
end
