require 'spec_helper'
require 'tempfile'

RSpec.describe Daru::IO::Exporters::Excel do
  context "writes to excel spreadsheet" do
    let(:a) { Daru::Vector.new(100.times.map { rand(100) }) }
    let(:b) { Daru::Vector.new((['b'] * 100)) }
    let(:df) { Daru::DataFrame.new({ :b => b, :a => a }) }
    let(:tempfile) { Tempfile.new('test_write.xls') }
    subject { Daru::IO::Importers::Excel.load tempfile.path }

    before { Daru::IO::Exporters::Excel.write df, tempfile.path}

    it { is_expected.to be_an(Daru::DataFrame) }
    it { is_expected.to eq(df) }
  end
end
