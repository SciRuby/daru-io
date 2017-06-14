RSpec.describe Daru::IO::Exporters::SQL do
  include_context 'exporter setup'

  let(:dbh)            { double }
  let(:table)          { 'test' }
  let(:prepared_query) { double }

  it 'writes to an SQL table' do
    expect(dbh)
      .to receive(:prepare)
      .with("INSERT INTO #{table} (a,b,c,d) VALUES (?,?,?,?)")
      .and_return(prepared_query)

    df.each_row do |r|
      expect(prepared_query)
        .to receive(:execute)
        .with(*r.to_a).ordered
    end

    described_class.new(df, dbh, table).call
  end
end
