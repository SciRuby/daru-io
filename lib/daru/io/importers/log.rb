require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # Log Importer Class, that extends `read_rails_log` method
      # to `Daru::DataFrame`
      class Log < Base
        Daru::DataFrame.register_io_module :read_rails_log, self

        def initialize
          optional_gem 'request-log-analyzer', '~> 1.13.4', requires: 'request_log_analyzer'
        end

        ORDERS = {
          rails3: %i[method path ip timestamp line_type lineno source
                     controller action format params rendered_file
                     partial_duration status duration view db].freeze,

          apache: %i[remote_host remote_logname user timestamp http_method
                     path http_version http_status bytes_sent referer
                     user_agent line_type lineno source].freeze,

          amazon_s3: %i[bucket_owner bucket timestamp remote_ip requester request_id operation
                        key request_uri http_status error_code bytes_sent object_size total_time
                        turnaround_time referer user_agent line_type lineno source].freeze
        }.freeze

        # Reads data from a log file
        #
        # @!method self.read(path, format: :rails3)
        #
        # @param path [String] Path to log file, where the dataframe is to be
        #   imported from.
        #
        # @param format [Symbol] Format of log file, which can be :rails3, :apache or :amazon_s3
        #   default format set to :rails3
        #
        # @return [Daru::IO::Importers::Log]
        #
        # @example Reading from rails log file
        #   instance = Daru::IO::Importers::Log.read("rails_test.log")
        #
        # @example Reading from apache log file
        #   instance = Daru::IO::Importers::Log.new.read("apache_test.log", format: :apache)
        #
        # @example Reading from amazon s3 log file
        #   instance = Daru::IO::Importers::Log.new.read("amazon_s3_test.log", format: :amazon_s3)
        def read(path, format: :rails3)
          @format = format
          @file_data = RequestLogAnalyzer::Source::LogParser
                       .new(RequestLogAnalyzer::FileFormat.load(@format), source_files: path)
                       .map do |request|
                         ORDERS
                           .fetch(@format)
                           .map { |attr| request.attributes.include?(attr) ? request.attributes[attr] : nil }
                       end
          self
        end

        # Imports a `Daru::DataFrame` from a Log Importer instance and log file
        #
        # @return [Daru::DataFrame]
        #
        # @example Reading from a log file
        #   df = instance.call
        #
        #   => #<Daru::DataFrame(150x17)>
        #   #         method       path         ip  timestamp  line_type     lineno     source contr...
        #   #   0        GET          /  127.0.0.1 2018022607  completed          5  /home/roh Rails...
        #   #   1        GET          /  127.0.0.1 2018022716  completed         12  /home/roh Rails...
        #   # ...        ...        ...        ...        ...        ...        ...        ...      ...
        def call
          Daru::DataFrame.rows(@file_data, order: ORDERS.fetch(@format))
        end
      end
    end
  end
end
