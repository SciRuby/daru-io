require "spec_helper"

RSpec.describe Daru::IO::Importers::CSV do
  it "parses CSV files with format-1" do
    expect(Daru::IO::Importers::CSV.load).to eq("CSVHelper#manipulate called by CSV#load")
  end
end
