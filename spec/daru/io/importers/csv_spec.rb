RSpec.describe Daru::IO::Importers::CSV do
  before do
    %w[matrix_test repeated_fields scientific_notation sales-funnel column_headers_only].each do |file|
      WebMock
        .stub_request(:get,"http://dummy-remote-url/#{file}.csv")
        .to_return(status: 200, body: File.read("spec/fixtures/csv/#{file}.csv"))
      WebMock.disable_net_connect!(allow: /dummy-remote-url/)
    end
  end

  subject    { described_class.new.read(path).call(opts) }

  let(:path) { 'spec/fixtures/csv/matrix_test.csv' }
  let(:opts) { {col_sep: ' ', headers: true}       }

  context 'loads from a CSV file' do
    let('subject.vectors') { %I[image_resolution mls true_transform].to_index }

    it_behaves_like 'exact daru dataframe',
      ncols: 3,
      nrows: 99,
      order: %i[image_resolution mls true_transform],
      :'image_resolution.first' => 6.55779,
      :'true_transform.first'   => '-0.2362347,0.6308649,0.7390552,0,0.6523478'\
                                   ',-0.4607318,0.6018043,0,0.7201635,0.6242881'\
                                   ',-0.3027024,4262.65,0,0,0,1'
  end

  context 'works properly for repeated headers' do
    let(:path)  { 'spec/fixtures/csv/repeated_fields.csv' }
    let(:opts)  { {header_converters: :symbol}            }

    it_behaves_like 'exact daru dataframe',
      ncols: 7,
      nrows: 6,
      order: %w[id name_1 age_1 city a1 name_2 age_2],
      age_2: Daru::Vector.new([3, 4, 5, 6, nil, 8])
  end

  context 'accepts scientific notation as float' do
    let(:path) { 'spec/fixtures/csv/scientific_notation.csv' }
    let(:opts) { {order: %w[x y]}                            }
    let(:df)   { subject                                     }

    it_behaves_like 'exact daru dataframe',
      ncols: 2,
      nrows: 3,
      order: %w[x y]

    # @note If a better syntax is possible without naming the subject,
    # feel free to suggest / adopt it.
    #
    #   Signed off by @athityakumar on 31/05/2017 at 10:25PM
    it 'checks for float accuracy' do
      y = [9.629587310436753e+127, 1.9341543147883677e+129, 3.88485279048245e+130]
      y.zip(df['y']).each do |y_expected, y_ds|
        expect(y_ds).to be_within(0.001).of(y_expected)
      end
    end
  end

  context 'follows the order of columns given in CSV' do
    let(:path)  { 'spec/fixtures/csv/sales-funnel.csv' }
    let(:opts)  { {}                                   }

    it_behaves_like 'exact daru dataframe',
      ncols: 8,
      nrows: 17,
      order: %w[Account Name Rep Manager Product Quantity Price Status]
  end

  context 'parses empty dataframe from CSV with only headers' do
    let(:path)  { 'spec/fixtures/csv/column_headers_only.csv' }
    let(:opts)  { {} }

    it_behaves_like 'exact daru dataframe',
      ncols: 3,
      nrows: 0,
      order: %w[col0 col1 col2]
  end

  context 'skips rows from CSV files with headers option' do
    let(:path)  { 'spec/fixtures/csv/sales-funnel.csv' }
    let(:opts)  { {skiprows: 8, headers: true} }

    it_behaves_like 'exact daru dataframe',
      ncols: 8,
      nrows: 9,
      order: %i[account manager name price product quantity rep status]
  end

  context 'skips rows from CSV files without headers option' do
    let(:path)  { 'spec/fixtures/csv/sales-funnel.csv' }
    let(:opts)  { {skiprows: 8} }

    it_behaves_like 'exact daru dataframe',
      ncols: 8,
      nrows: 9,
      order: %w[Account Name Rep Manager Product Quantity Price Status]
  end

  context 'checks for equal parsing of csv and csv.gz files' do
    %w[matrix_test repeated_fields scientific_notation sales-funnel column_headers_only].each do |file|
      before { Zlib::GzipWriter.open(path) { |gz| gz.write File.read(csv_path) } }

      let(:csv_path) { "spec/fixtures/csv/#{file}.csv"     }
      let(:tempfile) { Tempfile.new("#{file}.csv.gz")      }
      let(:csv)      { described_class.read(csv_path).call }
      let(:path)     { tempfile.path                       }
      let(:opts)     { {compression: :gzip}                }

      it_behaves_like 'a daru dataframe'
      it { is_expected.to eq(csv) }
    end
  end

  context 'checks for equal parsing of local CSV files and remote CSV files' do
    %w[matrix_test repeated_fields scientific_notation sales-funnel column_headers_only].each do |file|
      let(:local) { described_class.read("spec/fixtures/csv/#{file}.csv").call }
      let(:path)  { "http://dummy-remote-url/#{file}.csv"                      }
      let(:opts)  { {}                                                         }

      it_behaves_like 'a daru dataframe'
      it { is_expected.to eq(local) }
    end
  end
end
