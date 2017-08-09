RSpec.describe Daru::IO::Exporters::Avro do
  subject do
    Daru::DataFrame.new(
      ::Avro::DataFile::Reader.new(
        StringIO.new(File.read(tempfile.path)),
        ::Avro::IO::DatumReader.new
      ).to_a
    )
  end

  include_context 'exporter setup'

  let(:filename) { 'test.avro' }

  before { described_class.new(df, tempfile.path, schema).call }

  context 'writes DataFrame to an Avro file' do
    context 'when schema is Hash' do
      let(:schema) do
        {
          'type' => 'record',
          'name' => 'test',
          'fields' => [
            {'name' => 'a', 'type' => 'int'},
            {'name' => 'b', 'type' => 'int'},
            {'name' => 'c', 'type' => %w[int string]},
            {'name' => 'd', 'type' => %w[int string null]}
          ]
        }
      end

      it_behaves_like 'exact daru dataframe',
        ncols: 4,
        nrows: 5,
        order: %w[a b c d],
        data: [
          [1,2,3,4,5],
          [11,22,33,44,55],
          ['a', 'g', 4, 5,'addadf'],
          [nil, 23, 4,'a','ff']
        ]
    end

    context 'when schema is Avro::Schema' do
      let(:schema) do
        ::Avro::Schema.parse(
          {
            'type' => 'record',
            'name' => 'test',
            'fields' => [
              {'name' => 'a', 'type' => 'int'},
              {'name' => 'b', 'type' => 'int'},
              {'name' => 'c', 'type' => %w[int string]},
              {'name' => 'd', 'type' => %w[int string null]}
            ]
          }.to_json
        )
      end

      it_behaves_like 'exact daru dataframe',
        ncols: 4,
        nrows: 5,
        order: %w[a b c d],
        data: [
          [1,2,3,4,5],
          [11,22,33,44,55],
          ['a', 'g', 4, 5,'addadf'],
          [nil, 23, 4,'a','ff']
        ]
    end
  end
end
