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
  let(:opts)     { {}          }
  let(:orient)   { :records    }
  let(:pretty)   { true        }
  let(:filename) { 'test.json' }

  before { described_class.new(df, tempfile.path, pretty: pretty, orient: orient, **opts).call }

  context 'writes DataFrame with default jsonpath options' do
    it                { is_expected.to be_an(Array).and all be_a(Hash) }
    its(:count)       { is_expected.to eq(3)                           }
    its('first.keys') { is_expected.to match_array(%w[name age sex])   }
  end

  context 'writes DataFrame with orient: :values' do
    let(:orient) { :values }

    it          { is_expected.to be_an(Array).and all be_an(Array)                     }
    its(:count) { is_expected.to eq(3)                                                 }
    its(:first) { is_expected.to eq(['Jon Snow', 'Rhaegar Targaryen', 'Lyanna Stark']) }
  end

  context 'writes DataFrame with orient: :split' do
    let(:orient) { :split }

    it          { is_expected.to be_a(Hash).and all be_an(Array) }
    its(:count) { is_expected.to eq(3)                           }
    its(:keys)  { is_expected.to eq(%w[vectors index data])      }
  end

  context 'writes DataFrame with orient: :index' do
    let(:orient) { :index }

    it          { is_expected.to be_an(Array).and all be_a(Hash)                                     }
    its(:count) { is_expected.to eq(3)                                                               }
    its(:first) { is_expected.to eq('child' => {'sex' => 'Male', 'age' => 18, 'name' => 'Jon Snow'}) }
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

  context 'writes DataFrame with block manipulation' do
    before do
      described_class.new(df, tempfile.path, orient: orient, pretty: pretty) do |json|
        json.map { |j| [j.keys.first, j.values.first] }.to_h
      end.call
    end

    let(:orient) { :index }

    it                  { is_expected.to be_a(Hash)                                             }
    its(:keys)          { is_expected.to eq(%w[child dad mom])                                  }
    its('values.first') { is_expected.to eq('sex' => 'Male', 'age' => 18, 'name' => 'Jon Snow') }
  end
end
