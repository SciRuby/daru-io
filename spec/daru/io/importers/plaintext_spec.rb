require "spec_helper"

RSpec.describe Daru::IO::Importers::Plaintext do

  context "reads data from plain text files" do
    let(:path) { 'spec/fixtures/plaintext/bank2.dat' }
    let(:vectors) { [:v1,:v2,:v3,:v4,:v5,:v6] }
    subject { Daru::DataFrame.from_plaintext(path, vectors) }

    it { is_expected.to be_an(Daru::DataFrame) }
    its('vectors.to_a') { is_expected.to eq(
				[:v1,:v2,:v3,:v4,:v5,:v6]
    	)
	  }
  end

  context "understands empty fields", :skip => 'See FIXME note at importers/plainext.rb#L33-L36' do
    let(:path) { 'spec/fixtures/plaintext/empties.dat' }
    let(:vectors) { [:v1,:v2,:v3] }
    subject { Daru::DataFrame.from_plaintext(path, vectors) }

    it { is_expected.to be_an(Daru::DataFrame) }
    its('row[1].to_a') { is_expected.to eq( 
    		[4, nil, 6]
    	)
	  }
  end

  context "understands non-numeric fields" do
    let(:path) { 'spec/fixtures/plaintext/strings.dat' }
    let(:vectors) { [:v1,:v2,:v3] }
    subject { Daru::DataFrame.from_plaintext(path, vectors) }

    it { is_expected.to be_an(Daru::DataFrame) }
    its('v1.to_a') { is_expected.to eq( 
    		['test', 'foo']
    	)
	  }
  end
end
