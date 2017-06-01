require 'daru/io/importers/linkages/activerecord'

module Daru
  module IO
    module Importers
      module Activerecord
        class << self
          def load(relation, *fields)
            if fields.empty?
              records = relation.map do |record|
                record.attributes.symbolize_keys
              end
              return Daru::DataFrame.new(records)
            else
              fields = fields.map(&:to_sym)
            end

            vectors = fields.map { |name| [name, Daru::Vector.new([], name: name)] }.to_h

            Daru::DataFrame.new(vectors, order: fields).tap do |df|
              relation.pluck(*fields).each do |record|
                df.add_row(Array(record))
              end
              df.update
            end
          end
        end
      end
      module ActiverecordHelper
        class << self
        end
      end
    end
  end
end
