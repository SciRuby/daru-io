RSpec.describe Daru::IO::Importers::CSV do # rubocop:disable Metrics/BlockLength
  before do
    %w[matrix_test repeated_fields scientific_notation sales-funnel].each do |file|
      WebMock
        .stub_request(:get,"http://dummy-remote-url/#{file}.csv")
        .to_return(status: 200, body: File.read("spec/fixtures/csv/#{file}.csv"))
      WebMock.disable_net_connect!(allow: /dummy-remote-url/)
    end
  end

  let(:path) { 'spec/fixtures/csv/matrix_test.csv' }
  let(:opts) { {col_sep: ' ', headers: true} }
  subject    { described_class.new(path, opts).call }

  context 'loads from a CSV file' do
    let('subject.vectors') { %I[image_resolution mls true_transform].to_index }

    it_behaves_like 'daru dataframe'
    its('image_resolution.first') { is_expected.to eq(6.55779) }
    its('true_transform.first') do
      is_expected.to eq(
        '-0.2362347,0.6308649,0.7390552,0,0.6523478,-0.4607318,'\
        '0.6018043,0,0.7201635,0.6242881,-0.3027024,4262.65,0,0,0,1'
      )
    end
  end

  context 'works properly for repeated headers' do
    let(:path)  { 'spec/fixtures/csv/repeated_fields.csv' }
    let(:opts)  { {header_converters: :symbol} }
    let(:order) { %w[id name_1 age_1 city a1 name_2 age_2] }

    it_behaves_like 'csv importer'
    its('age_2') { is_expected.to eq(Daru::Vector.new([3, 4, 5, 6, nil, 8])) }
  end

  context 'accepts scientific notation as float' do
    let(:path)  { 'spec/fixtures/csv/scientific_notation.csv' }
    let(:opts)  { {order: %w[x y]} }
    let(:order) { %w[x y] }

    it_behaves_like 'csv importer'
    # SPOILER ALERT : If a better syntax is possible without naming the subject,
    # feel free to suggest / adopt it.
    #
    # Signed off by @athityakumar on 31/05/2017 at 10:25PM
    it 'checks for float accuracy' do
      y = [9.629587310436753e+127, 1.9341543147883677e+129, 3.88485279048245e+130]
      y.zip(subject['y']).each do |y_expected, y_ds|
        expect(y_ds).to be_within(0.001).of(y_expected)
      end
    end
  end

  context 'follows the order of columns given in CSV' do
    let(:path)  { 'spec/fixtures/csv/sales-funnel.csv' }
    let(:opts)  { {} }
    let(:order) { %w[Account Name Rep Manager Product Quantity Price Status] }

    it_behaves_like 'csv importer'
  end

  context 'checks for equal parsing of local CSV files and remote CSV files' do
    %w[matrix_test repeated_fields scientific_notation sales-funnel].each do |file|
      let(:local) { described_class.new("spec/fixtures/csv/#{file}.csv").call }
      let(:path)  { "http://dummy-remote-url/#{file}.csv" }
      let(:opts)  { {} }

      it_behaves_like 'daru dataframe'
      it { is_expected.to eq(local) }
    end
  end
end
