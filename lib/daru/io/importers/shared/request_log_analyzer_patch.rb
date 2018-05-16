module RequestLogAnalyzerPatch
  module RequestLogAnalyzer::Source # rubocop:disable Style/ClassAndModuleChildren
    # LogParser class, that reads log data from a given source and uses a file format
    # definition to parse all relevent information about requests from the file
    class LogParser
      # Patch for the gem request-log-analyzer version 1.13.4 to combine the methods parse_file,
      # parse_io and parse_line of the LogParser class. Assigns all the necessary instance
      # variables defined in the above specified methods. Creates a request for each line of
      # the file stream and stores the hash of parsed information in raw_list. Each element of
      # parsed_list is an array of one parsed entry in log file.
      def parse_hash(file) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        log_file         = File.open(file, 'rb')
        @max_line_length = max_line_length
        @line_divider    = line_divider
        @current_lineno  = 0
        @file_format     = file_format
        @current_source  = File.expand_path(file)
        raw_list         = []
        while (line = log_file.gets(@line_divider, @max_line_length))
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
          parsed_list[i] = Daru::IO::Importers::RailsLog::ORDER
                           .map { |attr| parsed_list[i].include?(attr) ? parsed_list[i][attr] : nil }
        end
        parsed_list
      end
    end
  end
end
