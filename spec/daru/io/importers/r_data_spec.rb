RSpec.describe Daru::IO::Importers::RData do
  subject { described_class.new(path, variable, index: index).call }

  let(:index)    { nil }
  let(:variable) { nil }

  context 'reads data from a variable in RData file' do
    let(:path)     { 'spec/fixtures/rdata/ACScounty.RData' }
    let(:variable) { :ACS3                                 }

    it_behaves_like 'exact daru dataframe',
      ncols: 30,
      nrows: 1629,
      index: (0..1628).to_a,
      order: %w[
        Abbreviation FIPS Non.US State cnty females.divorced females.married ind-agric
        ind-arts ind-construc ind-educational ind-finance ind-information ind-manufact
        ind-other.industry ind-public.admin ind-retail ind-scientific ind-transport
        ind-wholesale males.diorced males.married median.earnings perc.HS+ perc.disability
        perc.no.health.insurance race-am.ind race-asian race-black race-white
      ]
  end

  context 'reads data from RDS file with index' do
    let(:path)     { 'spec/fixtures/rdata/ACScounty.RData' }
    let(:index)    { 'FIPS'                                }
    let(:variable) { :ACS3                                 }

    it_behaves_like 'exact daru dataframe',
      ncols: 29,
      nrows: 1629,
      order: %w[
        Abbreviation Non.US State cnty females.divorced females.married ind-agric
        ind-arts ind-construc ind-educational ind-finance ind-information ind-manufact
        ind-other.industry ind-public.admin ind-retail ind-scientific ind-transport
        ind-wholesale males.diorced males.married median.earnings perc.HS+ perc.disability
        perc.no.health.insurance race-am.ind race-asian race-black race-white
      ]
  end
end
