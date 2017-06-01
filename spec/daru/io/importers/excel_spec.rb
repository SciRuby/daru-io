require 'spec_helper'

RSpec.describe Daru::IO::Importers::Excel do
  context "loads from excel spreadsheet" do
    let(:id) { Daru::Vector.new([1, 2, 3, 4, 5, 6]) }
    let(:name) { Daru::Vector.new(%w(Alex Claude Peter Franz George Fernand)) }
    let(:age) { Daru::Vector.new( [20, 23, 25, nil, 5.5, nil]) }
    let(:city) { Daru::Vector.new(['New York', 'London', 'London', 'Paris', 'Tome', nil]) }
    let(:a1) { Daru::Vector.new(['a,b', 'b,c', 'a', nil, 'a,b,c', nil]) }
    let(:path) { 'spec/fixtures/excel/test_xls.xls' }

    subject { Daru::IO::Importers::Excel.load path }

    it { is_expected.to be_an(Daru::DataFrame) }
    its(:nrows) { is_expected.to eq(6) }
    its('vectors.to_a') { is_expected.to eq([:id, :name, :age, :city, :a1]) }
    its('age.to_a.last') { is_expected.to eq(nil) }
    it { is_expected.to eq(Daru::DataFrame.new({
        :id => id, :name => name, :age => age, :city => city, :a1 => a1
        }, order: [:id, :name, :age, :city, :a1]))}
  end
end
