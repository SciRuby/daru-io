RSpec.describe Daru::IO::Exporters::CSV do
  context "writes DataFrame to a CSV file" do
  let(:df) { 
    Daru::DataFrame.new({
      'a' => [1,2,3,4,5],
      'b' => [11,22,33,44,55],
      'c' => ['a', 'g', 4, 5,'addadf'],
      'd' => [nil, 23, 4,'a','ff']})
  }
  let(:tempfile) { Tempfile.new('data.csv') }

    before { Daru::IO::Exporters::CSV.write df, tempfile.path }
    subject { Daru::IO::Importers::CSV.load tempfile.path }

    it { is_expected.to be_an(Daru::DataFrame) }
    it { is_expected.to eq(df) }
  end

  context "writes headers unless headers=false" do
  let(:df) { 
    Daru::DataFrame.new({
      'a' => [1,2,3,4,5],
      'b' => [11,22,33,44,55],
      'c' => ['a', 'g', 4, 5,'addadf'],
      'd' => [nil, 23, 4,'a','ff']})
  }
  let(:tempfile) { Tempfile.new('data.csv') }

    before { Daru::IO::Exporters::CSV.write df, tempfile.path }
    subject { File.open(tempfile.path, &:readline).chomp.split(',', -1) }
    
    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.vectors.to_a) }
  end

  context "won't write headers when headers=false" do
  let(:df) { 
    Daru::DataFrame.new({
      'a' => [1,2,3,4,5],
      'b' => [11,22,33,44,55],
      'c' => ['a', 'g', 4, 5,'addadf'],
      'd' => [nil, 23, 4,'a','ff']})
  }
  let(:tempfile) { Tempfile.new('data.csv') }

    let(:headers) { false }
    before { Daru::IO::Exporters::CSV.write df, tempfile.path, headers: headers }
    subject { File.open(tempfile.path, &:readline).chomp.split(',', -1) }

    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.head(1).map { |v| (v.first || '').to_s }) }
  end
end



