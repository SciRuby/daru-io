RSpec.describe Daru::IO::Importers::RDS do
  subject { described_class.new(path).call }

  let(:index) { nil }

  context 'reads data from RDS file' do
    let(:path) { 'spec/fixtures/rds/bc_sites.rds' }

    it_behaves_like 'exact daru dataframe',
      ncols: 25,
      nrows: 1113,
      index: (0..1112).to_a,
      order: %w[
        area description epa_reach format_version latitude location location_code location_type
        longitude name psc_basin psc_region record_code record_origin region reporting_agency
        rmis_basin rmis_latitude rmis_longitude rmis_region sector state_or_province sub_location
        submission_date water_type
      ]
  end
end
