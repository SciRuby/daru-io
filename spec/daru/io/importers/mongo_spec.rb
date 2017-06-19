RSpec.describe Daru::IO::Importers::Mongo do # rubocop:disable Metrics/BlockLength
  let(:connection)   { ::Mongo::Client.new('mongodb://127.0.0.1:27017/test')  }
  let(:collection)   { path.split('json').last.tr('/.','').to_sym             }
  let(:arrays)       { nil                                                    }
  let(:hashes)       { {}                                                     }
  let(:index)        { nil                                                    }
  let(:order)        { nil                                                    }
  let(:first_index)  { 0                                                      }
  let(:last_index)   { nil                                                    }
  let(:first_vector) { nil                                                    }
  let(:last_vector)  { nil                                                    }

  before do
    collection = path.split('json').last.tr('/.','').to_sym
    documents  = ::JSON.parse(File.read(path))
    if documents.is_a?(Array)
      connection[collection].insert_many documents
    else
      connection[collection].insert_one documents
    end
  end

  after { connection[collection].drop }

  subject { described_class.new(connection, collection, *arrays, order: order, index: index, **hashes).call }

  context 'on simple json file' do
    context 'in NASA data' do
      let(:path)         { 'spec/fixtures/json/nasadata.json' }
      let(:nrows)        { 202                                }
      let(:ncols)        { 11                                 }
      let(:last_index)   { 201                                }
      let(:last_vector)  { 'q_au_2'                           }
      let(:first_vector) { '_id'                              }

      context 'without xpath (simple json)' do
        it_behaves_like 'json importer'
      end
    end
  end

  it_behaves_like 'importer with json-path option'
end
