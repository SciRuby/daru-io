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

RSpec.shared_examples 'json importer' do
  it                        { is_expected.to be_a(Daru::DataFrame) }
  its(:nrows)               { is_expected.to eq(nrows)             }
  its(:ncols)               { is_expected.to eq(ncols)             }
  its('index.to_a.first')   { is_expected.to eq(first_index)       }
  its('index.to_a.last')    { is_expected.to eq(last_index)        }
  its('vectors.to_a.first') { is_expected.to eq(first_vector)      }
  its('vectors.to_a.last')  { is_expected.to eq(last_vector)       }
end

RSpec.shared_examples 'importer with json-path option' do
  context 'on nested json file' do
    context 'in temperature data' do
      let(:path)        { 'spec/fixtures/json/temp.json' }
      let(:nrows)       { 122                            }
      let(:ncols)       { 2                              }
      let(:last_index)  { 121                            }
      let(:last_vector) { :Val                           }

      context 'with only xpath array - default order' do
        let(:arrays)       { %w[value anomaly].map { |x| '$..data..'+x } }
        let(:last_vector)  { 'anomaly'                                   }
        let(:first_vector) { 'value'                                     }

        it_behaves_like 'json importer'
      end

      context 'with only xpath hash - custom order' do
        let(:first_vector) { :Anom }
        let(:hashes) do
          {
            Anom: '$..data..anomaly',
            Val: '$..data..value'
          }
        end

        it_behaves_like 'json importer'
      end

      context 'with both xpath array and hash' do
        let(:arrays)       { %w[$..data..anomaly]    }
        let(:hashes)       { {Val: '$..data..value'} }
        let(:first_vector) { 'anomaly' }

        it_behaves_like 'json importer'
      end
    end

    context 'in tv series data' do
      let(:path)         { 'spec/fixtures/json/got.json' }
      let(:nrows)        { 61                            }
      let(:ncols)        { 4                             }
      let(:last_index)   { 60                            }
      let(:last_vector)  { 'runtime'                     }
      let(:first_vector) { 'name'                        }

      context 'with xpath array' do
        let(:arrays) do
          %w[name season number runtime]
            .map { |x| '$.._embedded..episodes..' + x }
        end

        it_behaves_like 'json importer'
      end

      context 'with xpath hash' do
        let(:first_vector) { :Name    }
        let(:last_vector)  { :Runtime }
        let(:hashes) do
          {
            Name: '$.._embedded..episodes..name',
            Season: '$.._embedded..episodes..season',
            Number: '$.._embedded..episodes..number',
            Runtime: '$.._embedded..episodes..runtime'
          }
        end

        it_behaves_like 'json importer'
      end

      context 'with xpath array' do
        let(:first_index)  { 0        }
        let(:last_vector)  { :Runtime }
        let(:first_vector) { 'name'   }
        let(:arrays) { %w[$.._embedded..episodes..name $.._embedded..episodes..season] }
        let(:hashes) do
          {
            Number: '$.._embedded..episodes..number',
            Runtime: '$.._embedded..episodes..runtime'
          }
        end

        it_behaves_like 'json importer'
      end
    end

    context 'on allsets data' do
      let(:path)         { 'spec/fixtures/json/allsets.json' }
      let(:nrows)        { 18                                }
      let(:ncols)        { 3                                 }
      let(:last_index)   { 3                                 }
      let(:first_index)  { 94                                }
      let(:last_vector)  { 'mciNumber'                       }
      let(:first_vector) { 'artist'                          }

      context 'with xpath array' do
        let(:arrays) { %w[artist cmc mciNumber].map { |x| '$..LEA..cards..' + x } }
        let(:index)  { '$..LEA..cards..multiverseid' }

        it_behaves_like 'json importer'
      end
    end

    context 'on VAT data' do
      let(:path)         { 'spec/fixtures/json/jsonvat.json' }
      let(:nrows)        { 28                                }
      let(:ncols)        { 2                                 }
      let(:last_index)   { 'IE'                              }
      let(:first_index)  { 'DE'                              }
      let(:last_vector)  { 'periods'                         }
      let(:first_vector) { 'name'                            }

      context 'with xpath array' do
        let(:arrays) { %w[name periods].map { |x| '$..rates..'+x } }
        let(:index)  { '$..rates..code' }

        it_behaves_like 'json importer'
      end
    end
  end
end
