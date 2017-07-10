RSpec.describe Daru::IO::Importers::Excelx do
  subject { described_class.new(path, sheet: sheet, headers: headers).call }

  let(:sheet)   { 0    }
  let(:headers) { true }

  context 'parses default sheet' do
    let(:path) { 'spec/fixtures/excelx/Microcode.xlsx' }

    it          { is_expected.to be_an(Daru::DataFrame)    }
    its(:ncols) { is_expected.to eq(32)                    }
    its(:nrows) { is_expected.to eq(37)                    }
    its(:index) { is_expected.to eq((0..36).to_a.to_index) }
    its('State.first') { is_expected.to eq('FETCH0')       }
  end

  context 'parses named sheet' do
    let(:path)  { 'spec/fixtures/excelx/LOBSTAHS_rt.windows.xlsx' }
    let(:sheet) { 'LOBSTAHS_rt.windows' }

    it                       { is_expected.to be_an(Daru::DataFrame)                             }
    its(:ncols)              { is_expected.to eq(3)                                              }
    its(:nrows)              { is_expected.to eq(93)                                             }
    its(:vectors)            { is_expected.to eq(%w[lipid_class rt_win_max rt_win_min].to_index) }
    its(:index)              { is_expected.to eq((0..92).to_a.to_index)                          }
    its('lipid_class.first') { is_expected.to eq('DGCC')                                         }
  end

  context 'parses nil elements in sheet' do
    let(:path)  { 'spec/fixtures/excelx/Stock-counts-sheet.xlsx' }
    let(:sheet) { 2 }

    it                              { is_expected.to be_an(Daru::DataFrame)    }
    its(:ncols)                     { is_expected.to eq(7)                     }
    its(:nrows)                     { is_expected.to eq(15)                    }
    its(:index)                     { is_expected.to eq((0..14).to_a.to_index) }
    its('Item code.first')          { is_expected.to eq(nil)                   }
    its('Stock count number.first') { is_expected.to eq(1)                     }
    its(:vectors) do
      is_expected.to eq(
        [
          'Status','Stock count number','Item code','New','Description',
          'Stock count date','Offset G/L Inventory'
        ].to_index
      )
    end
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
