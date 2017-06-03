RSpec.shared_examples 'daru dataframe' do
  it            { is_expected.to be_a(Daru::DataFrame) }
  its(:vectors) { is_expected.to be_a(Daru::Index) }
end

RSpec.shared_examples 'sql activerecord importer' do
  it_behaves_like 'daru dataframe'
  its(:nrows)         { is_expected.to eq(2) }
  its('vectors.to_a') { is_expected.to eq(order) }
  it                  { is_expected.to eq(Daru::DataFrame.new(data,order: order)) }
end

RSpec.shared_examples 'sql helper importer' do |vectors, data|
  it_behaves_like 'daru dataframe'
  it          { expect(df.row[0]).to have_attributes(id: 1, age: 20) }
  its(:nrows) { is_expected.to eq 2 }
end

RSpec.shared_examples 'csv importer' do
  it_behaves_like 'daru dataframe'
  its('vectors.to_a') { is_expected.to eq(order)}
end

RSpec.shared_examples 'html importer' do |symbol|
  it          { is_expected.to be_an(Array).and all be_a(Daru::DataFrame) }
  its(symbol) { is_expected.to eq(df) }
end