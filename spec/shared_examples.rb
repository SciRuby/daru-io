RSpec.shared_examples 'json importer' do
  it                        { is_expected.to be_a(Daru::DataFrame) }
  its(:nrows)               { is_expected.to eq(nrows)             }
  its(:ncols)               { is_expected.to eq(ncols)             }
  its('index.to_a.first')   { is_expected.to eq(first_index)       }
  its('index.to_a.last')    { is_expected.to eq(last_index)        }
  its('vectors.to_a.first') { is_expected.to eq(first_vector)      }
  its('vectors.to_a.last')  { is_expected.to eq(last_vector)       }
end

RSpec.shared_examples 'exact daru dataframe' do |dataframe: nil, data: nil, nrows: nil, ncols: nil, order: nil, index: nil, name: nil, **opts| # rubocop:disable Metrics/LineLength
  it            { is_expected.to be_a(Daru::DataFrame) }

  it            { is_expected.to eq(dataframe)      } if dataframe
  its(:name)    { is_expected.to eq(name)           } if name
  its(:data)    { is_expected.to ordered_data(data) } if data
  its(:ncols)   { is_expected.to eq(ncols)          } if ncols
  its(:nrows)   { is_expected.to eq(nrows)          } if nrows
  its(:index)   { is_expected.to eq(index.to_index) } if index
  its(:vectors) { is_expected.to eq(order.to_index) } if order

  opts.each { |key, value| its(key.to_sym) { is_expected.to eq(value) } }
end
