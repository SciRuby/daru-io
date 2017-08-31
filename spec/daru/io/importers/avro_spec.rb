RSpec.describe Daru::IO::Importers::Avro do
  subject { described_class.read(path).call }

  let(:path) { '' }

  context 'on complex numbers avro file' do
    let(:path) { 'spec/fixtures/avro/one_complex.avro' }

    it_behaves_like 'exact daru dataframe',
      ncols: 2,
      nrows: 1,
      order: %w[re im],
      data: [[100],[200]]
  end

  context 'on twitter avro file' do
    let(:path) { 'spec/fixtures/avro/twitter.avro' }

    it_behaves_like 'exact daru dataframe',
      ncols: 3,
      nrows: 10,
      order: %w[username tweet timestamp],
      data: [
        %w[miguno BlizzardCS DarkTemplar VoidRay VoidRay DarkTemplar Immortal Immortal VoidRay DarkTemplar],
        [
          'Rock: Nerf paper, scissors is fine.',
          'Works as intended.  Terran is IMBA.',
          'From the shadows I come!',
          'Prismatic core online!',
          'Fire at will, commander.',
          'I am the blade of Shakuras!',
          'I return to serve!',
          'En Taro Adun!',
          'There is no greater void than the one between your ears.',
          'I strike from the shadows!'
        ],
        [
          136_615_068_1, 136_615_448_1, 136_615_468_1, 136_616_000_0, 136_616_001_0,
          136_617_468_1, 136_617_568_1, 136_617_628_3, 136_617_630_0, 136_618_468_1
        ]
      ]
  end

  context 'on users avro file' do
    let(:path) { 'spec/fixtures/avro/users.avro' }

    it_behaves_like 'exact daru dataframe',
      ncols: 3,
      nrows: 2,
      order: %w[name favorite_color favorite_numbers],
      data: [%w[Alyssa Ben],[nil, 'red'],[[3,9,15,20], []]]
  end
end
