RSpec.describe Daru::IO::Importers::Excelx do
  subject { described_class.new(path, opts).call }

  let(:opts) { {} }

  context 'when sheet is not specified' do
    let(:path) { 'spec/fixtures/excelx/Microcode.xlsx' }

    it_behaves_like 'exact daru dataframe',
      ncols: 32,
      nrows: 37,
      index: (0..36).to_a,
      :'State.first' => 'FETCH0'
  end

  context 'when sheet name is given' do
    let(:path) { 'spec/fixtures/excelx/LOBSTAHS_rt.windows.xlsx' }
    let(:opts) { {sheet: 'LOBSTAHS_rt.windows'} }

    it_behaves_like 'exact daru dataframe',
      ncols: 3,
      nrows: 93,
      order: %w[lipid_class rt_win_max rt_win_min],
      index: (0..92).to_a,
      :'lipid_class.first' => 'DGCC'
  end

  context 'when sheet contains nil elements' do
    let(:path) { 'spec/fixtures/excelx/Stock-counts-sheet.xlsx' }
    let(:opts) { {sheet: 2} }

    it_behaves_like 'exact daru dataframe',
      ncols: 7,
      nrows: 15,
      order: [
        'Status','Stock count number','Item code','New','Description',
        'Stock count date','Offset G/L Inventory'
      ],
      index: (0..14).to_a,
      :'Item code.first' => nil,
      :'Stock count number.first' => 1
  end

  context 'when skipping rows and columns' do
    let(:path) { 'spec/fixtures/excelx/pivot.xlsx' }
    let(:opts) { {sheet: 'Data1', skiprows: 2, skipcols: 1} }

    it_behaves_like 'exact daru dataframe',
      ncols: 9,
      nrows: 2155,
      index: (0..2154).to_a,
      :'Unit Price.first' => 14
  end

  before do
    %w[LOBSTAHS_rt.windows Microcode Stock-counts-sheet].each do |file|
      WebMock
        .stub_request(:get,"http://dummy-remote-url/#{file}.xlsx")
        .to_return(status: 200, body: File.read("spec/fixtures/excelx/#{file}.xlsx"))
      WebMock.disable_net_connect!(allow: /dummy-remote-url/)
    end
  end

  context 'checks for equal parsing of local XLSX files and remote XLSX files' do
    %w[LOBSTAHS_rt.windows Microcode Stock-counts-sheet].each do |file|
      let(:local) { described_class.new("spec/fixtures/excelx/#{file}.xlsx").call }
      let(:path)  { "http://dummy-remote-url/#{file}.xlsx" }

      it { is_expected.to be_an(Daru::DataFrame) }
      it { is_expected.to eq(local)              }
    end
  end
end
