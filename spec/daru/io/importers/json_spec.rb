RSpec.describe Daru::IO::Importers::JSON do
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

  it_behaves_like 'importer with json-path option'

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
