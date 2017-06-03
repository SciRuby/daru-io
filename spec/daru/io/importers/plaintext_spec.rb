RSpec.describe Daru::IO::Importers::Plaintext do
  let(:vectors) { [:v1,:v2,:v3] }
  subject { Daru::IO::Importers::Plaintext.load(path, vectors) }

  context "reads data from plain text files" do
    let(:path) { 'spec/fixtures/plaintext/bank2.dat' }
    let(:vectors) { [:v1,:v2,:v3,:v4,:v5,:v6] }

    it_behaves_like 'plaintext importer', 'vectors.to_a', [:v1,:v2,:v3,:v4,:v5,:v6]
  end

  context "understands empty fields", :skip => 'See FIXME note at importers/plainext.rb#L33-L36' do
    let(:path) { 'spec/fixtures/plaintext/empties.dat' }

    it_behaves_like 'plaintext importer', 'row[1].to_a', [4, nil, 6]
  end

  context "understands non-numeric fields" do
    let(:path) { 'spec/fixtures/plaintext/strings.dat' }

    it_behaves_like 'plaintext importer', 'v1.to_a', ['test', 'foo']
  end
end
