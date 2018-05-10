require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      class Rails < Base
        Daru::DataFrame.register_io_module :read_rails, self
        Daru::DataFrame.register_io_module :from_rails, self

        def initialize
          require 'request_log_analyzer'
          RequestLogAnalyzer::Source::LogParser.class_eval do
            def initialize(format, options = {})
              super(format, options)
              @warnings         = 0
              @parsed_lines     = 0
              @parsed_requests  = 0
              @skipped_lines    = 0
              @skipped_requests = 0
              @current_request  = nil
              @current_source   = nil
              @current_file     = nil
              @current_lineno   = nil
              @processed_files  = []
              @source_files     = options[:source_files]
              @progress_handler = nil
              @warning_handler  = nil
              @parsed_hash      = []

              @options[:parse_strategy] ||= RequestLogAnalyzer::Source::LogParser::DEFAULT_PARSE_STRATEGY
              unless RequestLogAnalyzer::Source::LogParser::PARSE_STRATEGIES
                      .include?(@options[:parse_strategy])
                fail "Unknown parse strategy: #{@options[@parse_strategy]}"
              end
            end

            def parse_file(file, options = {}, &block)
              if File.directory?(file)
                parse_files(Dir["#{ file }/*"], options, &block)
                return
              end

              @current_source = File.expand_path(file)
              @source_changes_handler.call(:started, @current_source) if @source_changes_handler

              if decompress_file?(file).empty?

                @progress_handler = @dormant_progress_handler
                @progress_handler.call(:started, file) if @progress_handler

                File.open(file, 'rb') { |f| parse_io(f, options, &block) }

                @progress_handler.call(:finished, file) if @progress_handler
                @progress_handler = nil

                @processed_files.push(@current_source.dup)

              else
                IO.popen(decompress_file?(file), 'rb') { |f| parse_io(f, options, &block) }
              end

              @source_changes_handler.call(:finished, @current_source) if @source_changes_handler

              @current_source = nil
              @parsed_hash
            end

            def update_current_request(request_data, &block) # :yields: request
              if alternative_header_line?(request_data)
                if @current_request
                  @current_request << request_data
                else
                  @current_request = @file_format.request(request_data)
                end
              elsif header_line?(request_data)
                if @current_request
                  case options[:parse_strategy]
                  when 'assume-correct'
                    handle_request(@current_request, &block)
                    @current_request = @file_format.request(request_data)
                  when 'cautious'
                    @skipped_lines += 1
                    warn(:unclosed_request, "Encountered header line (#{request_data[:line_definition].name.inspect}), but previous request was not closed!")
                    @current_request = nil # remove all data that was parsed, skip next request as well.
                  end
                elsif footer_line?(request_data)
                  handle_request(@file_format.request(request_data), &block)
                else
                  @current_request = @file_format.request(request_data)
                end
              else
                if @current_request
                  @current_request << request_data
                  if footer_line?(request_data)
                    handle_request(@current_request, &block) # yield @current_request
                    @current_request = nil
                  end
                else
                  @skipped_lines += 1
                  warn(:no_current_request, "Parseable line (#{request_data[:line_definition].name.inspect}) found outside of a request!")
                end
              end
              a = @file_format.request(request_data).attributes
              @parsed_hash << a if not a.nil?
            end
          end
        end

        def read(path)
          @path = path
          @file_data = parse(@path)
          self
        end

        def call()
          ind = [:method, :path, :ip, :timestamp, :line_type, :lineno, :source,
                 :controller, :action, :format, :params, :rendered_file,
                 :partial_duration, :status, :duration, :view, :db]
          data = Daru::DataFrame.new({},index: ind).transpose
          @file_data.each do |hash|
            row = []
            ind.each do |attr|
              row << hash[attr]
            end
            data.add_row row
          end
          data
        end

        def parse(path)
          subject = RequestLogAnalyzer::FileFormat.load(:rails3)
          log_parser = RequestLogAnalyzer::Source::LogParser.new(subject)
          raw_list = log_parser.parse_file(path)
          parsed_list = []
          raw_list.each do |hash|
            parsed_list << hash if hash.key? :method
          end
          for i in (0...parsed_list.size - 1)
            j = raw_list.index(parsed_list[i+1])
            k = raw_list.index(parsed_list[i]) + 1
            for l in (k...j)
              parsed_list[i].merge!(raw_list[l])
            end
          end
          parsed_list
        end
      end
    end
  end
end
