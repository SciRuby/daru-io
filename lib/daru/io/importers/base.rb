require 'daru/io/base'

module Daru
  module IO
    module Importers
      # Base Importer Class that contains generic helper methods, to be
      # used by other Importers via inheritence
      class Base < Daru::IO::Base
        # Guesses the `Daru::DataFrame` from the parsed set of key-value pairs.
        #
        # @param keys [Array] A set of keys from given key-value pairs
        # @param vals [Array] A set of values from given key-value pairs
        #
        # @example When key-value pairs contains values that is Array of Hashes
        #   Daru::IO::Importers::Base.guess_parse([:a], [[{ x: 1, y: 2 },{ x: 3, y: 4 }]])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      x   y
        #   #  0   1   2
        #   #  1   3   4
        #
        # @example When key-value pairs contains values that is Arrays
        #   Daru::IO::Importers::Base.guess_parse([:x, :y], [[1,3], [2,4]])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      x   y
        #   #  0   1   2
        #   #  1   3   4
        #
        # @example When key-value pairs contains Array of keys contain value Hashes
        #   Daru::IO::Importers::Base.guess_parse([:a, :b], [{ x: 1, y: 2 }, { x: 3, y: 4 }])
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #      x   y
        #   #  a   1   2
        #   #  b   3   4
        def self.guess_parse(keys, vals)
          case vals.first
          when Array
            case vals.first.first
            when Hash then Daru::DataFrame.new(vals.flatten)
            else Daru::DataFrame.rows(vals.transpose, order: keys)
            end
          when Hash then Daru::DataFrame.new(vals.flatten, index: keys)
          end
        end

        # Adds the `from` class method to all inheriting children Importer classes, which
        # calls corresponding Importer's `initialize` and instance method `from`.
        def self.from(relation)
          new.from(relation)
        end

        # Adds the `read` class method to all inheriting children Importer classes, which
        # calls corresponding Importer's `initialize` and instance method `read`.
        def self.read(path)
          new.read(path)
        end

        def self.parse_log(file,format)
          require 'request_log_analyzer'
          RequestLogAnalyzer::Source::LogParser.class_eval do
            def parse_hash(file)
              logfile = File.open(file, 'rb')
              @max_line_length = max_line_length
              @line_divider    = line_divider
              @current_lineno  = 0
              raw_list = []
              while line = logfile.gets(@line_divider, @max_line_length)
                @current_lineno += 1
                if request_data = @file_format.parse_line(line) { |wt, message| warn(wt, message) }
                  @parsed_lines += 1
                  raw_hash = @file_format.request(request_data).attributes
                  raw_list << raw_hash if not raw_hash.nil?
                end
              end
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
          RequestLogAnalyzer::Source::LogParser
            .new(RequestLogAnalyzer::FileFormat.load(format))
            .parse_hash(file)
        end
      end
    end
  end
end
