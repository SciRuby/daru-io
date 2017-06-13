# require 'daru/io/importers/linkages/json'
require 'json'
require 'open-uri'
require 'jsonpath'

module Daru
  module IO
    module Importers
      class JSON
        def initialize(path, *arrays, order: nil, index: nil, **hashes)
          @data       = []
          @path       = path
          @hashes     = hashes
          @arrays     = arrays
          @order      = order
          @index      = index
          @auto_order = []
        end

        def call
          json = ::JSON.parse(open(@path).read)

          if @hashes.empty?
            if @arrays.size == 1
              @data = get_xpath(json, @arrays.first)
            elsif @arrays.empty?
              parse_without_hash json
            else
              parse_with_array json
            end
          else
            parse_with_array json unless @arrays.empty?
            parse_with_hash json
          end

          @order ||= @auto_order
          Daru::DataFrame.new(@data, order: @order, index: @index)
        end

        private

        def get_xpath(json, xpath)
          case xpath
          when String
            JsonPath.on(json, xpath)
          when Array, Hash
            xpath
          when nil
            nil
          end
        end

        def parse_with_array(json)
          @data        += @arrays.map { |xpath| get_xpath(json, xpath) }
          @index        = get_xpath(json, @index)
          @auto_order  += @arrays.map { |xpath| xpath.split('..').last }
          @order        = get_xpath(json, @order)
        end

        def parse_with_hash(json)
          @data       += @hashes.values.map { |xpath| get_xpath(json, xpath) }
          @index       = get_xpath(json, @index)
          @auto_order += @hashes.keys
          @order       = get_xpath(json, @order)
        end

        def parse_without_hash(json)
          @data += json
        end
      end
    end
  end
end
