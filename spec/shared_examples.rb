RSpec.shared_examples 'activerecord importer' do |vectors, data|
  it { is_expected.to be_an(Daru::DataFrame) }
  its(:nrows) { is_expected.to eq(2) }
  its('vectors.to_a') { is_expected.to eq(vectors) }
  it { is_expected.to eq(Daru::DataFrame.new(data,order: vectors)) }
end

RSpec.shared_examples 'sql importer' do |vectors, data|
    it { is_expected.to be_a(Daru::DataFrame) }
    it { expect(df.row[0]).to have_attributes(id: 1, age: 20) }
    its(:nrows) { is_expected.to eq 2 }
end

RSpec.shared_examples 'plaintext importer' do |attr, attr_expectation|
    it { is_expected.to be_an(Daru::DataFrame) }
    its(attr) { is_expected.to eq(attr_expectation) }
end