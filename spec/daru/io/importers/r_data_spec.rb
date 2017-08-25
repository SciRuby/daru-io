RSpec.describe Daru::IO::Importers::RData do
  subject { described_class.new(variable).read(path) }

  let(:variable) { nil }

  context 'reads data from ACScounty file' do
    let(:path)     { 'spec/fixtures/rdata/ACScounty.RData' }
    let(:variable) { 'ACS3'                                }

    it_behaves_like 'exact daru dataframe',
      ncols: 30,
      nrows: 1629,
      index: (0..1628).to_a,
      order: %i[
        Abbreviation FIPS Non.US State cnty females.divorced females.married ind-agric
        ind-arts ind-construc ind-educational ind-finance ind-information ind-manufact
        ind-other.industry ind-public.admin ind-retail ind-scientific ind-transport
        ind-wholesale males.diorced males.married median.earnings perc.HS+ perc.disability
        perc.no.health.insurance race-am.ind race-asian race-black race-white
      ]
  end

  context 'reads data from Filings-by-state file' do
    let(:path)     { 'spec/fixtures/rdata/Filings-by-state.RData' }
    let(:variable) { 'bk.rates'                                   }

    it_behaves_like 'exact daru dataframe',
      ncols: 5,
      nrows: 1755,
      index: (0..1754).to_a,
      order: %i[
        Business.Filings Non.Business.Filings State.Code Total.Filings year
      ]
  end

  context 'reads data from Ownership file' do
    let(:path)     { 'spec/fixtures/rdata/Ownership.RData' }
    let(:variable) { 'ownership.state.qtr'                 }

    it_behaves_like 'exact daru dataframe',
      ncols: 4,
      nrows: 1632,
      index: (0..1631).to_a,
      order: %i[
        Date State own.rate se
      ]
  end

  context 'when not a data.frame variable in RData file' do # rubocop:disable RSpec/EmptyExampleGroup
    {
      'spec/fixtures/rdata/FRED-cpi-house.RData'  => 'cpi.house',
      'spec/fixtures/rdata/case-shiller.RData'    => 'case.shiller',
      'spec/fixtures/rdata/state-migration.RData' => 'state.migration',
      'spec/fixtures/rdata/zip-county.RData'      => 'zip'
    }.each do |path, variable|
      let(:path)     { path     }
      let(:variable) { variable }

      its_call { is_expected.to raise_error(ArgumentError) }
    end
  end
end
