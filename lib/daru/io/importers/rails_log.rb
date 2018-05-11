require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      class RailsLog < Base
        Daru::DataFrame.register_io_module :read_rails_log, self
        Daru::DataFrame.register_io_module :from_rails_log, self

        def initialize()
          @path = nil
          @file_data = nil
        end

        def read(path)
          @path = path
          @file_data = Base.parse_log(@path,:rails3)
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
      end
    end
  end
end
