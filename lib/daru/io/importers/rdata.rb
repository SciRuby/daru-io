require 'daru/io/importers/rds'

module Daru
  module IO
    module Importers
      class RData < RDS
        Daru::DataFrame.register_io_module :from_rdata, self

        # Imports a +Daru::DataFrame+ from an ActiveRecord Relation
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
        def initialize(path, variable, index: nil)
          super(path, index: index)
          @variable = variable
        end

        def call
          @instance = RSRuby.instance
          @instance.eval_R("load('#{@path}')")
          @vals     = @instance.send(@variable)
          @index    = @vals.delete(@index) if @index
          Daru::DataFrame.new(@vals, index: @index)
        end
      end
    end
  end
end
