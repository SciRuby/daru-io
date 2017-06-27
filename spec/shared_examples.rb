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

RSpec.shared_examples 'json importer' do
  it_behaves_like 'daru dataframe'
  its(:nrows)               { is_expected.to eq(nrows)             }
  its(:ncols)               { is_expected.to eq(ncols)             }
  its('index.to_a.first')   { is_expected.to eq(first_index)       }
  its('index.to_a.last')    { is_expected.to eq(last_index)        }
  its('vectors.to_a.last')  { is_expected.to eq(last_vector)       }
  its('vectors.to_a.first') { is_expected.to eq(first_vector)      }
end

RSpec.shared_examples 'importer with json-path option' do
  context 'in temperature data' do
    let(:path)        { 'spec/fixtures/json/temp.json' }
    let(:nrows)       { 122                            }
    let(:ncols)       { 2                              }
    let(:last_index)  { 121                            }
    let(:last_vector) { :Val                           }

    context 'with only jsonpath columns' do
      let(:columns)      { %w[value anomaly].map { |x| '$..data..'+x } }
      let(:last_vector)  { 1                                           }
      let(:first_vector) { 0                                           }

      it_behaves_like 'json importer'
    end

    context 'with only jsonpath named columns' do
      let(:first_vector) { :Anom }
      let(:named_columns) do
        {
          Anom: '$..data..anomaly',
          Val: '$..data..value'
        }
      end

      it_behaves_like 'json importer'
    end

    context 'with both jsonpath columns and named columns' do
      let(:columns)       { %w[$..data..anomaly]    }
      let(:first_vector)  { 0                       }
      let(:named_columns) { {Val: '$..data..value'} }

      it_behaves_like 'json importer'
    end
  end

  context 'in tv series data' do
    let(:path)         { 'spec/fixtures/json/got.json' }
    let(:nrows)        { 61                            }
    let(:ncols)        { 4                             }
    let(:last_index)   { 60                            }
    let(:last_vector)  { 3                             }
    let(:first_vector) { 0                             }

    context 'with jsonpath columns' do
      let(:columns) do
        %w[name season number runtime]
          .map { |x| '$.._embedded..episodes..' + x }
      end

      it_behaves_like 'json importer'
    end

    context 'with jsonpath named columns' do
      let(:first_vector) { :Name    }
      let(:last_vector)  { :Runtime }
      let(:named_columns) do
        {
          Name: '$.._embedded..episodes..name',
          Season: '$.._embedded..episodes..season',
          Number: '$.._embedded..episodes..number',
          Runtime: '$.._embedded..episodes..runtime'
        }
      end

      it_behaves_like 'json importer'
    end

    context 'with jsonpath columns' do
      let(:first_index)  { 0        }
      let(:last_vector)  { :Runtime }
      let(:first_vector) { 0        }
      let(:columns) { %w[$.._embedded..episodes..name $.._embedded..episodes..season] }
      let(:named_columns) do
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
    let(:last_vector)  { 2                                 }
    let(:first_vector) { 0                                 }

    context 'with jsonpath columns' do
      let(:columns) { %w[artist cmc mciNumber].map { |x| '$..LEA..cards..' + x } }
      let(:index)   { '$..LEA..cards..multiverseid'                              }

      it_behaves_like 'json importer'
    end
  end

  context 'on VAT data' do
    let(:path)         { 'spec/fixtures/json/jsonvat.json' }
    let(:nrows)        { 28                                }
    let(:ncols)        { 2                                 }
    let(:last_index)   { 'IE'                              }
    let(:first_index)  { 'DE'                              }
    let(:last_vector)  { 1                                 }
    let(:first_vector) { 0                                 }

    context 'with jsonpath columns' do
      let(:columns) { %w[name periods].map { |x| '$..rates..'+x } }
      let(:index)   { '$..rates..code'                            }

      it_behaves_like 'json importer'
    end
  end
end
