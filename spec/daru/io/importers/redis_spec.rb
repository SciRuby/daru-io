RSpec.describe Daru::IO::Importers::Redis do # rubocop:disable Metrics/BlockLength
  let(:connection) { Redis.new {} }
  subject { described_class.new(connection, *keys).call }

  before { index.each_with_index { |k,i| store(k, data[i]) } }

  def store(key, value)
    connection.set key, value.to_json
  end

  after { connection.flushdb }

  context 'on array of keys having hashes' do
    let(:index) { %i[10001 10002 10003 10004] }
    let(:data) do
      [
        {name: 'Tyrion',  age: 32},
        {name: 'Jamie',   age: 37},
        {name: 'Cersei',  age: 37},
        {name: 'Joffrey', age: 19}
      ]
    end

    context 'without key options' do
      let(:keys) { [] }

      it { is_expected.to eq(Daru::DataFrame.new(data, index: index)) }
    end

    context 'with key options' do
      let(:keys) { index[0..1] }

      it { is_expected.to eq(Daru::DataFrame.new(data[0..1], index: keys)) }
    end
  end

  context 'on keys having array of hashes' do
    let(:index) { %i[10001 10003] }
    let(:data) do
      [
        [{name: 'Tyrion', age: 32},{name: 'Jamie',   age: 37}],
        [{name: 'Cersei', age: 37},{name: 'Joffrey', age: 19}]
      ]
    end

    context 'without key options' do
      let(:keys) { [] }

      it { is_expected.to eq(Daru::DataFrame.new(data.flatten)) }
    end

    context 'with key options' do
      let(:keys) { index[0..0] }

      it { is_expected.to eq(Daru::DataFrame.new(data[0..0].flatten)) }
    end
  end

  context 'on hash keys having arrays' do
    let(:index) { %i[name age living] }
    let(:data) do
      [
        %w[Tyrion Jamie Cersei Joffrey],
        [32,37,37,19],
        [true, true, true, false]
      ]
    end

    context 'without key options' do
      let(:keys) { [] }

      it { is_expected.to eq(Daru::DataFrame.new(data, order: index)) }
    end

    context 'with key options' do
      let(:keys) { index[0..1] }

      it { is_expected.to eq(Daru::DataFrame.new(data[0..1], order: keys)) }
    end
  end
end
