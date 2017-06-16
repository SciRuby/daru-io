RSpec.describe Daru::IO::Importers::JSON do # rubocop:disable Metrics/BlockLength
  let(:path)         { ''  }
  let(:arrays)       { nil }
  let(:hashes)       { {}  }
  let(:index)        { nil }
  let(:order)        { nil }
  let(:first_index)  { 0   }
  let(:last_index)   { nil }
  let(:first_vector) { nil }
  let(:last_vector)  { nil }

  subject { described_class.new(path, *arrays, order: order, index: index, **hashes).call }

  context 'on simple json file' do
    context 'in NASA data' do
      let(:path)         { 'spec/fixtures/json/nasadata.json' }
      let(:nrows)        { 202                                }
      let(:ncols)        { 10                                 }
      let(:last_index)   { 201                                }
      let(:last_vector)  { 'q_au_2'                           }
      let(:first_vector) { 'designation'                      }

      context 'without xpath (simple json)' do
        it_behaves_like 'json importer'
      end
    end
  end

  context 'on nested json file' do # rubocop:disable Metrics/BlockLength
    context 'in temperature data' do # rubocop:disable Metrics/BlockLength
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

    context 'in tv series data' do # rubocop:disable Metrics/BlockLength
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

  context 'parses json response' do
    let(:path)         { ::JSON.parse(File.read('spec/fixtures/json/nasadata.json')) }
    let(:nrows)        { 202                                           }
    let(:ncols)        { 10                                            }
    let(:last_index)   { 201                                           }
    let(:last_vector)  { 'q_au_2'                                      }
    let(:first_vector) { 'designation'                                 }

    it_behaves_like 'json importer'
  end

  context 'parses json string' do
    let(:path)         { File.read('spec/fixtures/json/nasadata.json') }
    let(:nrows)        { 202                                           }
    let(:ncols)        { 10                                            }
    let(:last_index)   { 201                                           }
    let(:last_vector)  { 'q_au_2'                                      }
    let(:first_vector) { 'designation'                                 }

    it_behaves_like 'json importer'
  end

  context 'parses remote and local file similarly' do
    let(:local_path)   { 'spec/fixtures/json/nasadata.json'      }
    let(:path)         { 'http://dummy-remote-url/nasadata.json' }
    let(:nrows)        { 202                                     }
    let(:ncols)        { 10                                      }
    let(:last_index)   { 201                                     }
    let(:last_vector)  { 'q_au_2'                                }
    let(:first_vector) { 'designation'                           }

    before do
      WebMock
        .stub_request(:get, path)
        .to_return(status: 200, body: File.read(local_path))
      WebMock.disable_net_connect!(allow: /dummy-remote-url/)
    end

    it_behaves_like 'json importer'
  end
end
