RSpec.describe Daru::IO::Importers::RailsLog do
  subject { described_class.read(path).call }

  context 'parsing rails log' do
    let(:path) { 'spec/fixtures/rails_log/rails.log' }

    it_behaves_like 'exact daru dataframe',
      ncols: 17,
      nrows: 1,
      order: %i[method path ip timestamp line_type lineno source
                controller action format params rendered_file
                partial_duration status duration view db],
      :'timestamp.to_a' => [20_180_312_174_118],
      :'duration.to_a' => [0.097]
  end
end
