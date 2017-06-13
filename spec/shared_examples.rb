RSpec.shared_examples 'json importer' do
  it                        { is_expected.to be_a(Daru::DataFrame) }
  its(:nrows)               { is_expected.to eq(nrows)             }
  its(:ncols)               { is_expected.to eq(ncols)             }
  its('index.to_a.first')   { is_expected.to eq(first_index)       }
  its('index.to_a.last')    { is_expected.to eq(last_index)        }
  its('vectors.to_a.first') { is_expected.to eq(first_vector)      }
  its('vectors.to_a.last')  { is_expected.to eq(last_vector)       }
end