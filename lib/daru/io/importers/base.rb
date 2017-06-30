require 'daru/io/base'

module Daru
  module IO
    module Importers
      class Base < Daru::IO::Base
        def self.guess_parse(keys, vals)
          case vals.first
          when Array
            case vals.first.first
            when Hash
              # Array of hashes
              # key a :
              # [
              #   { x: 1, y: 2 },
              #   { x: 3, y: 4 }
              # ]
              Daru::DataFrame.new vals.flatten
            else
              # Hash containing Array
              # key a :
              # {
              #   x: [1,2,3,4]
              #   y: [5,6,7,8]
              # }
              Daru::DataFrame.rows vals.transpose, order: keys
            end
          when Hash
            # Array containing Hash
            # [
            #   key a: { x: 1, y: 2 }
            #   key b: { x: 3, y: 4 }
            # ]
            Daru::DataFrame.new vals.flatten, index: keys
          end
        end
      end
    end
  end
end
