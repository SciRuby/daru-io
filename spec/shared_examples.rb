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

RSpec.shared_examples 'sql helper importer' do
  it_behaves_like 'daru dataframe'
  it          { expect(df.row[0]).to have_attributes(id: 1, age: 20) }
  its(:nrows) { is_expected.to eq 2 }
end

RSpec.shared_examples 'csv importer' do
  it_behaves_like 'daru dataframe'
  its('vectors.to_a') { is_expected.to eq(order) }
end

RSpec.shared_examples 'html importer' do |symbol|
  it          { is_expected.to be_an(Array).and all be_a(Daru::DataFrame) }
  its(symbol) { is_expected.to eq(df) }
end

RSpec.shared_examples 'redis importer' do
  it_behaves_like 'daru dataframe'
  its(:data)    { is_expected.to unordered_dataframe(expected_data) }
  its(:ncols)   { is_expected.to eq(ncols)                          }
  its(:nrows)   { is_expected.to eq(nrows)                          }
  its(:index)   { is_expected.to belong_to(expected_index)          }
  its(:vectors) { is_expected.to belong_to(expected_vectors)        }
end

RSpec.shared_examples 'json importer' do
  it_behaves_like 'daru dataframe'
  its(:nrows)               { is_expected.to eq(nrows)             }
  its(:ncols)               { is_expected.to eq(ncols)             }
  its('index.to_a.first')   { is_expected.to eq(first_index)       }
  its('index.to_a.last')    { is_expected.to eq(last_index)        }
  its('vectors.to_a.last')  { is_expected.to eq(last_vector)       }
  its('vectors.to_a.first') { is_expected.to eq(first_vector)      }
end
