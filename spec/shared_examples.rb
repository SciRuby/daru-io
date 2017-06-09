RSpec.shared_examples 'redis importer' do
  it            { is_expected.to be_a(Daru::DataFrame)       }
  its(:index)   { is_expected.to belong_to(expected_index)   }
  its(:vectors) { is_expected.to belong_to(expected_vectors) }
  its(:data)    { is_expected.to contain_from(expected_data) }
end
