require 'daru/io/importers/base'
require 'daru/io/importers/shared/request_log_analyzer_patch'

module Daru
  module IO
    module Importers
      # RailsLog Importer Class, that extends `read_rails_log` methods
      # to `Daru::DataFrame`
      class RailsLog < Base
        include RequestLogAnalyzerPatch
        Daru::DataFrame.register_io_module :read_rails_log, self

        # initializes the instance variables @path and @file_data to nil
        def initialize
          @path = nil
          @file_data = nil
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
        def read(path)
          @path = path
          @file_data = RequestLogAnalyzerPatch.parse_log(@path,:rails3)
          self
        end

        # index of header of the parsed information
        INDEX = %i[method path ip timestamp line_type lineno source
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
          data = Daru::DataFrame.new({},index: INDEX).transpose
          @file_data.each do |hash|
            data.add_row(INDEX.map { |attr| hash[attr] })
          end
          data
        end
      end
    end
  end
end
