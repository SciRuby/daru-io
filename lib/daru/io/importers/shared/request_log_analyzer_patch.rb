module RequestLogAnalyzerPatch
  require 'request_log_analyzer'

  class RequestLogAnalyzer::Source::LogParser

    def parse_hash(file)
      logfile = File.open(file, 'rb')
      @max_line_length = max_line_length
      @line_divider    = line_divider
      @current_lineno  = 0
      @file_format     = file_format
      @current_source = File.expand_path(file)
      raw_list = []
      while line = logfile.gets(@line_divider, @max_line_length)
        @current_lineno += 1
        if request_data = @file_format.parse_line(line) { |wt, message| warn(wt, message) }
          request_data = request_data.merge(source: @current_source, lineno: @current_lineno)
          @parsed_lines += 1
          update_current_request(request_data)
          raw_hash = @file_format.request(request_data).attributes
          raw_list << raw_hash if not raw_hash.nil?
        end
      end
      parsed_list = []
      raw_list.each do |hash|
        parsed_list << hash if hash.key? :method
      end
      for i in (0...parsed_list.size)
        j = raw_list.index(parsed_list[i])
        k = raw_list.index(parsed_list[i+1])
        k = k.nil? ? raw_list.size : k
        for l in (j...k)
          parsed_list[i].merge!(raw_list[l])
        end
      end
      parsed_list
    end
  end

  def self.parse_log(path, format)
    RequestLogAnalyzer::Source::LogParser
      .new(RequestLogAnalyzer::FileFormat.load(format))
      .parse_hash(path)
  end
end
