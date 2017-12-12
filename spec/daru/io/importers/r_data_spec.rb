RSpec.describe Daru::IO::Importers::RData do
  subject { described_class.read(path).call(variable) }

  let(:variable) { nil }

  context 'reads data from ACScounty file' do
    let(:path)     { 'spec/fixtures/rdata/ACScounty.RData' }
    let(:variable) { 'ACS3'                                }

    it_behaves_like 'exact daru dataframe',
      ncols: 30,
      nrows: 1629,
      index: (0..1628).to_a,
      order: %i[
        State Abbreviation FIPS
        males.married males.diorced females.married females.divorced
        perc.HS+ Non.US perc.disability
        race-white race-black race-am.ind race-asian
        ind-agric ind-construc ind-manufact ind-wholesale ind-retail ind-transport ind-information
        ind-finance ind-scientific ind-educational ind-arts ind-other.industry ind-public.admin
        median.earnings perc.no.health.insurance cnty
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
        State.Code Total.Filings Business.Filings Non.Business.Filings year
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
        State Date own.rate se
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
