RSpec.describe Daru::IO::Importers::Mongo do
  let(:connection)    { ::Mongo::Client.new('mongodb://127.0.0.1:27017/test') }
  let(:collection)    { path.split('json').last.tr('/.','').to_sym            }
  let(:index)         { nil                                                   }
  let(:order)         { nil                                                   }
  let(:first_index)   { 0                                                     }
  let(:last_index)    { nil                                                   }
  let(:first_vector)  { nil                                                   }
  let(:last_vector)   { nil                                                   }
  let(:columns)       { nil                                                   }
  let(:named_columns) { {}                                                    }

  def store(path)
    collection = path.split('json').last.tr('/.','').to_sym
    documents = ::JSON.parse(File.read(path))
    if documents.is_a? Array
      connection[collection].insert_many(documents)
    else
      connection[collection].insert_one(documents)
    end
  end

  before { store path                  }
  after  { connection[collection].drop }

  subject { described_class.new(connection, collection, *columns, order: order, index: index, **named_columns).call }

  context 'on simple json file' do
    context 'in NASA data' do
      let(:path)       { 'spec/fixtures/json/nasadata.json' }
      let(:nrows)      { 202                                }
      let(:ncols)      { 11                                 }
      let(:last_index) { 201                                }
      let(:vector) do
        %w[_id designation discovery_date h_mag i_deg moid_au orbit_class period_yr pha q_au_1 q_au_2]
      end

      context 'without xpath (simple json)' do
        it_behaves_like 'mongo importer'
      end
    end
  end

  it_behaves_like 'importer with json-path option'
end
