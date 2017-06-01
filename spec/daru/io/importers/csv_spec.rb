require 'spec_helper'
require 'webmock/rspec'
require 'open-uri'

RSpec.describe Daru::IO::Importers::CSV do
  context "loads from a CSV file" do
    let(:path) { 'spec/fixtures/csv/matrix_test.csv' }
    let(:col_sep) { ' ' }
    let(:headers) { true }
    let(:df) { Daru::IO::Importers::CSV.load(path, col_sep: col_sep, headers: headers) }
    let('df.vectors') { [:image_resolution, :mls, :true_transform].to_index }
    subject { df }

		it { is_expected.to be_an(Daru::DataFrame) }
    its('image_resolution.first') { is_expected.to eq(6.55779)}
    its('true_transform.first') { is_expected.to eq("-0.2362347,0.6308649,0.7390552,0,0.6523478,-0.4607318,0.6018043,0,0.7201635,0.6242881,-0.3027024,4262.65,0,0,0,1")}
  end

  context "works properly for repeated headers" do
    let(:path) { 'spec/fixtures/csv/repeated_fields.csv' }
    let(:header_converters) { :symbol }
    subject { Daru::IO::Importers::CSV.load(path, header_converters: header_converters) }

		it { is_expected.to be_an(Daru::DataFrame) }
    its('vectors.to_a') { is_expected.to eq(["id", "name_1", "age_1", "city", "a1", "name_2", "age_2"])}
    its('age_2') { is_expected.to eq(Daru::Vector.new([3, 4, 5, 6, nil, 8]))}
  end

  context "accepts scientific notation as float" do
    let(:path) { 'spec/fixtures/csv/scientific_notation.csv' }
    let(:order) { ['x', 'y'] }
    subject(:ds) { Daru::IO::Importers::CSV.load(path, order: order) }

		it { is_expected.to be_an(Daru::DataFrame) }
    its('vectors.to_a') { is_expected.to eq(['x', 'y'])}

    # SPOILER ALERT : If a better syntax is possible without naming the subject,
    # feel free to suggest / adopt it.
    #
    # Signed off by @athityakumar on 31/05/2017 at 10:25PM
    it 'checks for float accuracy' do
	    y = [9.629587310436753e+127, 1.9341543147883677e+129, 3.88485279048245e+130]
	    y.zip(ds['y']).each do |y_expected, y_ds|
	      expect(y_ds).to be_within(0.001).of(y_expected)
	    end
  	end
  end

  context "follows the order of columns given in CSV" do
  	let(:path) { 'spec/fixtures/csv/sales-funnel.csv' }
  	subject { Daru::IO::Importers::CSV.load(path) }

		it { is_expected.to be_an(Daru::DataFrame) }
    its('vectors.to_a') { is_expected.to eq(%W[Account Name Rep Manager Product Quantity Price Status])}
  end

  context "checks for equal parsing of local CSV files and remote CSV files" do
    before do
	    %w[matrix_test repeated_fields scientific_notation sales-funnel].each do |file|
	      WebMock
	        .stub_request(:get,"http://dummy-remote-url/#{file}.csv")
	        .to_return(status: 200, body: File.read("spec/fixtures/csv/#{file}.csv"))
	      WebMock.disable_net_connect!(allow: %r{dummy-remote-url})
	    end
	  end

    %w[matrix_test repeated_fields scientific_notation sales-funnel].each do |file|
      let(:local) { Daru::IO::Importers::CSV.load("spec/fixtures/csv/#{file}.csv") }
      subject { Daru::IO::Importers::CSV.load("http://dummy-remote-url/#{file}.csv") }

			it { is_expected.to be_an(Daru::DataFrame) }
	    it { is_expected.to eq(local)}
    end
  end
end
