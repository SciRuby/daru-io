RSpec.describe Daru::IO::Importers::Log.new do
  context 'parsing rails log' do
    subject { described_class.read(path,format: :rails3).call }

    let(:path) { 'spec/fixtures/log/rails.log' }

    it_behaves_like 'exact daru dataframe',
      ncols: 17,
      nrows: 1,
      order: %i[method resource_path ip timestamp line_type lineno
                source controller action format params rendered_file
                partial_duration status duration view db],
      :'timestamp.to_a' => [20_180_312_174_118],
      :'duration.to_a' => [0.097]
  end

  context 'parsing apache log' do
    subject { described_class.read(path,format: :apache).call }

    let(:path) { 'spec/fixtures/log/apache.log' }

    it_behaves_like 'exact daru dataframe',
      ncols: 14,
      nrows: 1,
      order: %i[remote_host remote_logname user timestamp http_method
                resource_path http_version http_status bytes_sent
                referer user_agent line_type lineno source],
      :'timestamp.to_a' => [20_161_207_103_443],
      :'bytes_sent.to_a' => [571]
  end

  context 'parsing amazon_s3 log' do
    subject { described_class.read(path,format: :amazon_s3).call }

    let(:path) { 'spec/fixtures/log/s3.log' }

    it_behaves_like 'exact daru dataframe',
      ncols: 20,
      nrows: 1,
      order: %i[bucket_owner bucket timestamp remote_ip requester request_id operation
                key request_uri http_status error_code bytes_sent object_size total_time
                turnaround_time referer user_agent line_type lineno source],
      :'timestamp.to_a' => [20_150_612_054_010],
      :'turnaround_time.to_a' => [0.019]
  end
end
