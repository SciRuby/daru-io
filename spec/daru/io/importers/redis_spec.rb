RSpec::Matchers.define :belong_to do |expected|
  match { |actual| (expected.to_a.uniq - actual.to_a.uniq).empty? }
end

RSpec::Matchers.define :match_unordered_data do |expected|
  match do |actual|
    actual = actual.to_a.map { |x| x.data.to_a }.flatten.uniq
    expected.map!(&:values) unless expected.first.is_a? Array
    expected = expected.flatten.uniq
    (expected - actual).empty?
  end
end

RSpec.shared_examples 'unordered daru dataframe' do |data: nil, nrows: nil, ncols: nil, order: nil, index: nil, name: nil, **opts| # rubocop:disable Metrics/LineLength
  it_behaves_like 'a daru dataframe',
    name: name,
    nrows: nrows,
    ncols: ncols,
    **opts

  its(:data)    { is_expected.to match_unordered_data(data) } if data
  its(:index)   { is_expected.to belong_to(index.to_index)  } if index
  its(:vectors) { is_expected.to belong_to(order.to_index)  } if order
end

# @note
#
#   Custom matchers +belong_to+ and +unordered_data+ have been used,
#   as Redis doesn't necessarily insert keys in the given order. Due
#   to this, some rows and columns might be jumbled, and there is no
#   way to expect for an exact match while testing on RSpec. Rather,
#   the DataFrame is tested to have the same data, in *ANY* order.
#
#   Signed off by @athityakumar on 08/16/2017 at 10:00PM IST
RSpec.describe Daru::IO::Importers::Redis do
  subject { described_class.from(connection).call(*keys, match: pattern, count: count) }

  let(:keys)             { []                    }
  let(:count)            { nil                   }
  let(:pattern)          { nil                   }
  let(:connection)       { Redis.new(port: 6379) }

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
      it_behaves_like 'unordered daru dataframe',
        nrows: 4,
        ncols: 2,
        index: %i[10001 10002 10003 10004],
        order: %i[name age],
        data: [
          ['Tyrion', 32],
          ['Jamie', 37],
          ['Cersei', 37],
          ['Joffrey', 19]
        ]
    end

    context 'with key options' do
      let(:keys)  { index[0..1] }

      it_behaves_like 'unordered daru dataframe',
        nrows: 2,
        ncols: 2,
        index: %i[10001 10002],
        order: %i[name age],
        data: [
          ['Tyrion', 32],
          ['Jamie', 37]
        ]
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
      it_behaves_like 'unordered daru dataframe',
        nrows: 4,
        ncols: 2,
        index: (0..3).to_a,
        order: %i[name age],
        data: [
          ['Tyrion', 32],
          ['Jamie', 37],
          ['Cersei', 37],
          ['Joffrey', 19]
        ]
    end

    context 'with key options' do
      let(:keys)  { index[0..0] }

      it_behaves_like 'unordered daru dataframe',
        nrows: 2,
        ncols: 2,
        index: (0..1).to_a,
        order: %i[name age],
        data: [
          ['Tyrion', 32],
          ['Jamie', 37]
        ]
    end
  end

  context 'on hash keys having arrays' do
    let(:index) { %i[age living name] }
    let(:data) do
      [
        [32,37,37,19],
        [true, true, true, false],
        %w[Tyrion Jamie Cersei Joffrey]
      ]
    end

    context 'without key options' do
      it_behaves_like 'unordered daru dataframe',
        nrows: 4,
        ncols: 3,
        index: (0..3).to_a,
        order: %i[name age living],
        data: [
          [32, true, 'Tyrion'],
          [37, true, 'Jamie'],
          [37, true, 'Cersei'],
          [19, false, 'Joffrey']
        ]
    end

    context 'with key options' do
      let(:keys) { index[0..1] }

      it_behaves_like 'unordered daru dataframe',
        nrows: 4,
        ncols: 2,
        index: (0..3).to_a
    end
  end

  context 'on timestamps' do
    let(:index) { %i[090620171216 090620171218 090620171222 100620171225] }
    let(:data) do
      [
        {name: 'Tyrion',  age: 32},
        {name: 'Jamie',   age: 37},
        {name: 'Cersei',  age: 37},
        {name: 'Joffrey', age: 19}
      ]
    end

    context 'gets keys with pattern match and count' do
      let(:count)   { 3           }
      let(:pattern) { '09062017*' }

      it_behaves_like 'unordered daru dataframe',
        nrows: 3,
        ncols: 2,
        index: %i[090620171216 090620171218 090620171222],
        order: %i[name age],
        data: [
          ['Tyrion', 32],
          ['Jamie', 37],
          ['Cersei', 37]
        ]
    end

    context 'gets keys without pattern and count' do
      it_behaves_like 'unordered daru dataframe',
        nrows: 4,
        ncols: 2,
        index: %i[090620171216 090620171218 090620171222],
        order: %i[name age],
        data: [
          ['Tyrion', 32],
          ['Jamie', 37],
          ['Cersei', 37],
          ['Joffrey', 19]
        ]
    end

    context 'gets keys with pattern match' do
      let(:pattern) { '09062017*' }

      it_behaves_like 'unordered daru dataframe',
        nrows: 3,
        ncols: 2,
        index: %i[090620171216 090620171218 090620171222],
        order: %i[name age],
        data: [
          ['Tyrion', 32],
          ['Jamie', 37],
          ['Cersei', 37]
        ]
    end
  end

  context 'on dummy data of paginated keys' do
    let(:data)    { Array.new(2000) { |i| {a: "a#{i}", b: "b#{i}"} } }
    let(:index)   { Array.new(2000) { |i| "key#{i}".to_sym }         }
    let(:pattern) { 'key1*'                                          }

    context 'parses only 1st page by default' do
      let(:count) { 400 }

      it_behaves_like 'unordered daru dataframe',
        nrows: 400,
        ncols: 2,
        order: %i[a b]
    end

    context 'parses entire pagination' do
      let(:count) { nil }

      it_behaves_like 'unordered daru dataframe',
        nrows: 1111,
        ncols: 2,
        order: %i[a b]
    end
  end
end
