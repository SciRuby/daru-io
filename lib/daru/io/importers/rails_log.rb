require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # RailsLog Importer Class, that extends `read_rails_log` methods
      # to `Daru::DataFrame`
      class RailsLog < Base
        Daru::DataFrame.register_io_module :read_rails_log, self

        # Checks for required gem dependencies of RailsLog importer
        # and requires the patch for request-log-analyzer gem
        def initialize
          optional_gem 'request-log-analyzer', '~> 1.13.4', requires: 'request_log_analyzer'
          require 'daru/io/importers/shared/request_log_analyzer_patch'
        end

        # Reads data from a rails log file
        #
        # @!method self.read(path)
        #
        # @param path [String] Path to rails log file, where the dataframe is to be
        #   imported from.
        #
        # @return [Daru::IO::Importers::RailsLog]
        #
        # @example Reading from plaintext file
        #   instance = Daru::IO::Importers::RailsLog.read("rails_test.log")
        def read(path, format: :rails3)
          parser = RequestLogAnalyzer::Source::LogParser.new(RequestLogAnalyzer::FileFormat.load(format))
          parser.extend(RequestLogAnalyzerPatch)
          @file_data = parser.parse_hash(path)
          self
        end

        # header of the parsed information
        ORDER = %i[method path ip timestamp line_type lineno source
                   controller action format params rendered_file
                   partial_duration status duration view db].freeze

        # Imports a `Daru::DataFrame` from a RailsLog Importer instance and rails log file
        #
        # @return [Daru::DataFrame]
        #
        # @example Reading from a rails log file
        #   df = instance.call
        #
        #   => #<Daru::DataFrame(150x17)>
        #   #         method       path         ip  timestamp  line_type     lineno     source contr...
        #   #   0        GET          /  127.0.0.1 2018022607  completed          5  /home/roh Rails...
        #   #   1        GET          /  127.0.0.1 2018022716  completed         12  /home/roh Rails...
        #   # ...        ...        ...        ...        ...        ...        ...        ...      ...
        def call
          Daru::DataFrame.rows(@file_data, order: ORDER)
        end
      end
    end
  end
end
