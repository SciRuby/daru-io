RSpec.describe Daru::IO::Importers::HTML do
  subject { described_class.read(path).call(opts)[df_index] }

  let(:opts)     { {} }
  let(:df_index) { 0  }

  context 'in wiki info table' do
    let(:path)  { "file://#{Dir.pwd}/spec/fixtures/html/wiki_table_info.html" }
    let(:order) { %w[FName LName Age]                                         }
    let(:index) { %w[One Two Three Four Five Six Seven]                       }
    let(:name)  { 'Wikipedia Information Table'                               }

    context 'returns default dataframe' do
      it_behaves_like 'exact daru dataframe',
        ncols: 3,
        nrows: 7,
        order: ['First name','Last name','Age'],
        data: [
          %w[Tinu Blaszczyk Lily Olatunkboh Adrienne Axelia Jon-Kabat],
          %w[Elejogun Kostrzewski McGarrett Chijiaku Anthoula Athanasios Zinn],
          %w[14 25 16 22 22 22 22]
        ]
    end

    context 'returns user-modified dataframe' do
      let(:opts) { {order: order, index: index, name: name} }

      it_behaves_like 'exact daru dataframe',
        ncols: 3,
        nrows: 7,
        order: %w[FName LName Age],
        index: %w[One Two Three Four Five Six Seven],
        name: 'Wikipedia Information Table',
        data: [
          %w[Tinu Blaszczyk Lily Olatunkboh Adrienne Axelia Jon-Kabat],
          %w[Elejogun Kostrzewski McGarrett Chijiaku Anthoula Athanasios Zinn],
          %w[14 25 16 22 22 22 22]
        ]
    end
  end

  context 'in wiki climate data' do
    let(:path) { "file://#{Dir.pwd}/spec/fixtures/html/wiki_climate.html" }

    context 'returns default dataframe' do
      it_behaves_like 'exact daru dataframe',
        ncols: 13,
        nrows: 10,
        order: %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec Year],
        index: [
          'Record high °C (°F)', 'Average high °C (°F)', 'Daily mean °C (°F)',
          'Average low °C (°F)', 'Record low °C (°F)',
          'Average rainfall mm (inches)', 'Average rainy days',
          'Average relative humidity (%)', 'Mean monthly sunshine hours',
          'Mean daily sunshine hours'
        ]
    end
  end

  context 'with valid html table markups' do
    let(:path)  { "file://#{Dir.pwd}/spec/fixtures/html/valid_markup.html" }
    let(:index) { %w[W X Y Z]                                              }
    let(:name)  { 'Small HTML table with index'                            }

    context 'returns user-modified dataframe' do
      let(:opts) { {index: index, name: name} }

      it_behaves_like 'exact daru dataframe',
        ncols: 2,
        nrows: 4,
        order: %w[a b],
        index: %w[W X Y Z],
        name: 'Small HTML table with index',
        data: [%w[6 4 9 7], %w[7 0 4 0]]
    end
  end

  context 'in year-wise passengers figure' do
    let(:path)  { "file://#{Dir.pwd}/spec/fixtures/html/macau.html" }
    let(:match) { '2001'                                            }
    let(:name)  { 'Year-wise Passengers Figure'                     }

    context 'returns matching dataframes with index' do
      let(:opts) { {match: match, name: name} }

      it_behaves_like 'exact daru dataframe',
        ncols: 6,
        nrows: 13,
        order: %w[2001 2000 1999 1998 1997 1996],
        index: %w[January February March April May June July August September October November December Total],
        name: 'Year-wise Passengers Figure',
        data: [
          ['265,603','184,381','161,264','161,432','117,984',''],
          ['249,259','264,066','209,569','168,777','150,772',''],
          ['312,319','226,483','186,965','172,060','149,795',''],
          ['351,793','296,541','237,449','180,241','179,049',''],
          ['338,692','288,949','230,691','172,391','189,925',''],
          ['332,630','271,181','231,328','157,519','175,402',''],
          ['344,658','304,276','243,534','205,595','173,103',''],
          ['360,899','300,418','257,616','241,140','178,118',''],
          ['291,817','280,803','210,885','183,954','163,385',''],
          ['327,232','298,873','231,251','205,726','176,879',''],
          ['315,538','265,528','228,637','181,677','146,804',''],
          ['314,866','257,929','210,922','183,975','151,362',''],
          ['3,805,306','3,239,428','2,640,111','2,214,487','1,952,578','0']
        ].transpose
    end
  end

  context 'in share market data' do
    let(:path)  { "file://#{Dir.pwd}/spec/fixtures/html/moneycontrol.html" }
    let(:match) { 'Sun Pharma'                                             }
    let(:index) { %w[Alpha Beta Gamma Delta Misc]                          }
    let(:name)  { 'Share Market Analysis' }

    context 'returns matching dataframes' do
      let(:opts) { {match: match} }

      it_behaves_like 'exact daru dataframe',
        ncols: 4,
        nrows: 5,
        order: ['Company','Price','Change','Value (Rs Cr.)'],
        data: [
          ['Sun Pharma','502.60','-65.05','2,117.87'],
          ['Reliance','1356.90','19.60','745.10'],
          ['Tech Mahindra','379.45','-49.70','650.22'],
          ['ITC','315.85','6.75','621.12'],
          ['HDFC','1598.85','50.95','553.91']
        ].transpose
    end

    context 'returns user-modified matching dataframes' do
      let(:opts) { {match: match, index: index, name: name} }

      it_behaves_like 'exact daru dataframe',
        ncols: 4,
        nrows: 5,
        order: ['Company','Price','Change','Value (Rs Cr.)'],
        index: %w[Alpha Beta Gamma Delta Misc],
        name: 'Share Market Analysis',
        data: [
          ['Sun Pharma','502.60','-65.05','2,117.87'],
          ['Reliance','1356.90','19.60','745.10'],
          ['Tech Mahindra','379.45','-49.70','650.22'],
          ['ITC','315.85','6.75','621.12'],
          ['HDFC','1598.85','50.95','553.91']
        ].transpose
    end
  end

  context 'in election results data' do
    let(:path) { "file://#{Dir.pwd}/spec/fixtures/html/eciresults.html" }

    context 'returns default dataframes' do
      it_behaves_like 'exact daru dataframe',
        ncols: 2,
        nrows: 19,
        order: ['PartyName', 'Votes Wise(%)']
    end
  end
end
