RSpec.describe Daru::IO::Exporters::CSV do
  include_context 'csv exporter setup'
  context 'writes DataFrame to a CSV file' do
    let(:opts) { {} }
    let(:content) { CSV.read(tempfile.path) }

    def convert input
      if input.to_i.to_s == input # Integer in string
        input.to_i
      elsif input.to_f.to_s == input
        input.to_f
      elsif input == "nil"
        nil
      else
        input
      end 
    end
    subject { Daru::DataFrame.rows content[1..-1].map { |x| x.map { |y| convert(y) } }, order: content[0] }

    it_behaves_like 'daru dataframe'
    it { is_expected.to eq(df) }
  end

  context 'writes headers unless headers=false' do
    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.vectors.to_a) }
  end

  context 'does not write headers when headers=false' do
    let(:headers) { false }
    let(:opts)    { { headers: headers } }
    
    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.head(1).map { |v| (v.first || '').to_s }) }
  end
end
