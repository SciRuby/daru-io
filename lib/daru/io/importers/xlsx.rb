require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      class XLSX < Base
        Daru::DataFrame.register_io_module :from_xlsx, self

        # Imports a +Daru::DataFrame+ from a given XLSX file and sheet.
        #
        # @param relation [ActiveRecord::Relation] A relation to be used to load
        #   the contents of DataFrame
        # @param fields [String or Array of Strings] A set of fields to load from.
        #
        # @return A +Daru::DataFrame+ imported from the given relation and fields
        #
        # @example Importing from an ActiveRecord relation without specifying fields
        #   df = Daru::IO::Importers::ActiveRecord.new(Account.all).call
        #   df
        #
        #   #=> #<Daru::DataFrame(2x3)>
        #   #=>        id  name   age
        #   #=>   0     1 Homer    20
        #   #=>   1     2 Marge    30
        #
        # @example Importing from an ActiveRecord relation by specifying fields
        #   df = Daru::IO::Importers::ActiveRecord.new(Account.all, :id, :name).call
        #   df
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #=>        id  name
        #   #=>   0     1 Homer
        #   #=>   1     2 Marge
        def initialize(path, sheet=0, headers: true)
          optional_gem 'roo', '~> 2.7.0'

          @path    = path
          @sheet   = sheet
          @headers = headers

          raise_errors
        end

        def call
          book      = Roo::Excelx.new(@path)
          worksheet = book.sheet(@sheet)
          data      = worksheet.to_a
          data      = strip_html_tags(data)
          order     = @headers ? data.delete_at(0) : (0..data.first.length-1).to_a

          Daru::DataFrame.rows(data, order: order)
        end

        private

        def raise_errors
          raise ArgumentError, "No XLSX file found in the given path #{@path}." unless File.exist?(@path)
        end

        def strip_html_tags(data)
          data.map do |row|
            row.map do |ele|
              next ele unless ele.is_a?(String)
              ele.gsub(/<[^>]+>/, '')
            end
          end
        end
      end
    end
  end
end
