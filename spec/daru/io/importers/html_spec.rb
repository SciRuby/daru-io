RSpec.describe Daru::IO::Importers::HTML do
  context "raises error when mechanize gem is not installed" do
    subject { -> { Daru::IO::Importers::HTMLHelper.raise_error } }
    it  { is_expected.to raise_error('Install the mechanize gem version 2.7.5 with `gem install mechanize`, for using the from_html function.') }
  end

  subject { Daru::IO::Importers::HTML.load(path, opts) }

  context 'in wiki info table' do
    let(:path)  { "file://#{Dir.pwd}/spec/fixtures/html/wiki_table_info.html" }
    let(:order) { ["FName", "LName", "Age"] }
    let(:index) { ["One", "Two", "Three", "Four", "Five", "Six", "Seven"] }
    let(:name)  { "Wikipedia Information Table" }

    context 'returns default dataframe' do
      let(:opts) { {} }
      let(:df)   {
        Daru::DataFrame.new(
          [["Tinu", "Blaszczyk", "Lily", "Olatunkboh", "Adrienne", "Axelia", "Jon-Kabat"],
          ["Elejogun", "Kostrzewski", "McGarrett", "Chijiaku", "Anthoula", "Athanasios", "Zinn"],
          ["14", "25", "16", "22", "22", "22", "22"]], 
          order: ["First name","Last name","Age"]
        )
      }
      
      it_behaves_like 'html importer', :first
    end

    context 'returns user-modified dataframe' do
      let(:opts) { { order: order, index: index, name: name } }
      let(:df)   {
        Daru::DataFrame.new(
          [["Tinu", "Blaszczyk", "Lily", "Olatunkboh", "Adrienne", "Axelia", "Jon-Kabat"],
          ["Elejogun", "Kostrzewski", "McGarrett", "Chijiaku", "Anthoula", "Athanasios", "Zinn"],
          ["14", "25", "16", "22", "22", "22", "22"]], 
          order: ["FName","LName", "Age"],
          index: ["One", "Two", "Three", "Four", "Five", "Six", "Seven"],
          name: "Wikipedia Information Table"
        )
      }

      it_behaves_like 'html importer', :first
    end
  end

  context 'in wiki climate data' do
    let(:path)  { "file://#{Dir.pwd}/spec/fixtures/html/wiki_climate.html" }

    context 'returns default dataframe' do
      let(:opts)  { {} }
      let(:df) { 
        Daru::Index.new(
          ["Record high °C (°F)", "Average high °C (°F)", "Daily mean °C (°F)", "Average low °C (°F)", "Record low °C (°F)", "Average rainfall mm (inches)", "Average rainy days", "Average relative humidity (%)", "Mean monthly sunshine hours", "Mean daily sunshine hours"]
        ) 
      }

      it_behaves_like 'html importer', 'first.index'
    end
  end

  context 'with valid html table markups' do
    let(:path) { "file://#{Dir.pwd}/spec/fixtures/html/valid_markup.html" }

    context 'returns user-modified dataframe' do
      let(:opts) { { index: ["W","X","Y","Z"], name: "Small HTML table with index" } }
      let(:df)   { 
        Daru::DataFrame.new(
          [["6", "4","9","7"],["7","0","4","0"]],
          order: ["a","b"],
          index: ["W","X","Y","Z"],
          name: "Small HTML table with index"
        )
      }

      it_behaves_like 'html importer', :first
    end     
  end

  context 'in year-wise passengers figure' do
    let(:path) { "file://#{Dir.pwd}/spec/fixtures/html/macau.html" }

    context 'returns matching dataframes with index' do
      let(:opts) { { match: "2001", name: "Year-wise Passengers Figure" } }
      let(:df) {
        Daru::DataFrame.new(
          [
            ["265,603","184,381","161,264","161,432","117,984",""],
            ["249,259","264,066","209,569","168,777","150,772",""],
            ["312,319","226,483","186,965","172,060","149,795",""],
            ["351,793","296,541","237,449","180,241","179,049",""],
            ["338,692","288,949","230,691","172,391","189,925",""],          
            ["332,630","271,181","231,328","157,519","175,402",""],          
            ["344,658","304,276","243,534","205,595","173,103",""],          
            ["360,899","300,418","257,616","241,140","178,118",""],          
            ["291,817","280,803","210,885","183,954","163,385",""],          
            ["327,232","298,873","231,251","205,726","176,879",""],          
            ["315,538","265,528","228,637","181,677","146,804",""],          
            ["314,866","257,929","210,922","183,975","151,362",""],          
            ["3,805,306","3,239,428","2,640,111","2,214,487","1,952,578","0"]
          ].transpose,
          order: ["2001","2000","1999","1998","1997","1996"],
          index: ["January","February","March","April","May","June","July","August","September","October","November","December","Total"],
          name: "Year-wise Passengers Figure"
        )
      }

      it_behaves_like 'html importer', :first
      its('first.index') { is_expected.to eq(Daru::Index.new(
            ["January","February","March","April","May","June","July","August","September","October","November","December","Total"]
          )
        )
      }
    end     
  end

  context 'in share market data' do
    let(:path)  { "file://#{Dir.pwd}/spec/fixtures/html/moneycontrol.html" }
    let(:match) { "Sun Pharma" }
    let(:index) { ["Alpha", "Beta", "Gamma", "Delta", "Misc"] }
    let(:name)  { "Share Market Analysis" }

    context 'returns matching dataframes' do
      let(:opts) { { match: match } }
      let(:df)   {
        Daru::DataFrame.new(
          [
            ["Sun Pharma","502.60","-65.05","2,117.87"],
            ["Reliance","1356.90","19.60","745.10"],
            ["Tech Mahindra","379.45","-49.70","650.22"],
            ["ITC","315.85","6.75","621.12"],
            ["HDFC","1598.85","50.95","553.91"]
          ].transpose,
          order: ["Company","Price","Change","Value (Rs Cr.)"]
        )
      }

      it_behaves_like 'html importer', :first
    end     

    context 'returns user-modified matching dataframes' do
      let(:opts) { { match: match, index: index, name: name } }
      let(:df)   {
        Daru::DataFrame.new(
          [
            ["Sun Pharma","502.60","-65.05","2,117.87"],
            ["Reliance","1356.90","19.60","745.10"],
            ["Tech Mahindra","379.45","-49.70","650.22"],
            ["ITC","315.85","6.75","621.12"],
            ["HDFC","1598.85","50.95","553.91"]
          ].transpose,
          order: ["Company","Price","Change","Value (Rs Cr.)"],
          index: ["Alpha", "Beta", "Gamma", "Delta", "Misc"],
          name: "Share Market Analysis"
        )
      }

      it_behaves_like 'html importer', :first
    end     

  end

  context 'in election results data' do
    let(:path)  { "file://#{Dir.pwd}/spec/fixtures/html/eciresults.html" }

    context 'returns default dataframes' do
      let(:opts)  { {} }
      let(:df) { Daru::Index.new(["PartyName", "Votes Wise(%)"]) }

      it_behaves_like 'html importer', 'first.vectors'
    end     
  end
end