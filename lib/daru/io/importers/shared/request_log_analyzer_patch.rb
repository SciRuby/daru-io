module RequestLogAnalyzerPatch
  require 'request_log_analyzer'

  module RequestLogAnalyzer::Source # rubocop:disable Style/ClassAndModuleChildren
    # LogParser class, that reads log data from a given source and uses a file format
    # definition to parse all relevent information about requests from the file
    class LogParser
      # Uses the gem request_log_analyzer to get a hash of parsed information of rails log file
      #
      # @!method self.parse_hash(file)
      #
      # @param file [String] Path to rails log file, where the hash is obtained from
      #
      # @return [Array]
      #
      # @example Reading from rails log file
      #   format   = RequestLogAnalyzer::FileFormat.load(:rails3)
      #   instance = RequestLogAnalyzer::Source::LogParser.new(format)
      #   list     = instance.parse_hash('test_rails.log')
      def parse_hash(file) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        logfile = File.open(file, 'rb')
        @max_line_length = max_line_length
        @line_divider    = line_divider
        @current_lineno  = 0
        @file_format     = file_format
        @current_source  = File.expand_path(file)
        raw_list         = []
        while (line = logfile.gets(@line_divider, @max_line_length))
          @current_lineno += 1
          unless (request_data = @file_format.parse_line(line) { |wt, message| warn(wt, message) })
            next
          end
          request_data = request_data.merge(source: @current_source, lineno: @current_lineno)
          @parsed_lines += 1
          update_current_request(request_data)
          raw_hash = @file_format.request(request_data).attributes
          raw_list << raw_hash unless raw_hash.nil?
        end
        parsed_list = []
        raw_list.each do |hash|
          parsed_list << hash if hash.key? :method
        end
        (0...parsed_list.size).each do |i|
          j = raw_list.index(parsed_list[i])
          k = raw_list.index(parsed_list[i+1])
          k = k.nil? ? raw_list.size : k
          (j...k).each do |l|
            parsed_list[i].merge!(raw_list[l])
          end
        end
        parsed_list
      end
    end
  end

  # Creates a LogParser class and parses the log file
  #
  # @!method self.parse_log(path, format)
  #
  # @param path [String] Path to rails log file, where the hash is obtained from
  #
  # @param format [Symbol] format of the log file, which can be :rails3, :apache, or :amazon_s3
  #
  # @return [Array] Array of hashes, each hash contains parsed information of one record in log file
  #
  # @example Reading from rails log file
  #   instance = RequestLogAnalyzerPatch.parse_log('test_rails.log',:rails3)
  def self.parse_log(path, format)
    RequestLogAnalyzer::Source::LogParser
      .new(RequestLogAnalyzer::FileFormat.load(format))
      .parse_hash(path)
  end
end
