# @note
#
#   Custom matchers +belong_to+ and +contain_from+ have been used,
#   as Redis doesn't necessarily insert keys in the given order. Due
#   to this, some rows and columns might be jumbled, and there is no
#   way to expect for an exact match while testing on RSpec. Rather,
#   the DataFrame is tested to have the same data, in *ANY* order.
#
#   Signed off by @athityakumar on 08/16/2017 at 10:00PM IST

RSpec.describe Daru::IO::Importers::Redis do # rubocop:disable Metrics/BlockLength
  let(:keys)             { []                    }
  let(:count)            { nil                   }
  let(:pattern)          { nil                   }
  let(:connection)       { Redis.new(port: 6379) }
  let(:expected_data)    { data                  }
  let(:expected_index)   { (0..3)                }
  let(:expected_vectors) { %i[name age]          }

  subject { described_class.new(connection, *keys, match: pattern, count: count).call }

  before { index.each_with_index { |k,i| store(k, data[i]) } }

  def store(key, value)
    connection.set key, value.to_json
  end

  after { connection.flushdb }

  context 'on array of keys having hashes' do
    let(:index)          { %i[10001 10002 10003 10004] }
    let(:expected_index) { index                       }
    let(:data) do
      [
        {name: 'Tyrion',  age: 32},
        {name: 'Jamie',   age: 37},
        {name: 'Cersei',  age: 37},
        {name: 'Joffrey', age: 19}
      ]
    end

    context 'without key options' do
      it_behaves_like 'redis importer'
    end

    context 'with key options' do
      let(:keys) { index[0..1] }
      it_behaves_like 'redis importer'
    end
  end

  context 'on keys having array of hashes' do
    let(:index)         { %i[10001 10003] }
    let(:expected_data) { data.flatten    }
    let(:data) do
      [
        [{name: 'Tyrion', age: 32},{name: 'Jamie',   age: 37}],
        [{name: 'Cersei', age: 37},{name: 'Joffrey', age: 19}]
      ]
    end

    context 'without key options' do
      it_behaves_like 'redis importer'
    end

    context 'with key options' do
      let(:keys) { index[0..0] }
      it_behaves_like 'redis importer'
    end
  end

  context 'on hash keys having arrays' do
    let(:index)            { %i[age living name] }
    let(:expected_vectors) { index               }
    let(:data) do
      [
        [32,37,37,19],
        [true, true, true, false],
        %w[Tyrion Jamie Cersei Joffrey]
      ]
    end

    context 'without key options' do
      it_behaves_like 'redis importer'
    end

    context 'with key options' do
      let(:keys) { index[0..1] }
      it_behaves_like 'redis importer'
    end
  end
end
