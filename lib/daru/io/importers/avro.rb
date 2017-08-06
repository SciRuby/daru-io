require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      class Avro < Base
        Daru::DataFrame.register_io_module :from_avro, self

        # Imports a +Daru::DataFrame+ from an Avro file.
        #
        # @param path [String] Path to Avro file, where the dataframe is to be imported from.
        #
        # @return A +Daru::DataFrame+ imported from the given relation and fields
        #
        # @example Importing from an Avro file
        #   df = Daru::IO::Importers::Avro.new("azorahai.avro").call
        #
        #   #=> #<Daru::DataFrame(3x3)>
        #   #        name points winner
        #   #    0   Dany    100   true
        #   #    1    Jon    100   true
        #   #    2 Tyrion    100   true
        def initialize(path)
          optional_gem 'avro'
          optional_gem 'snappy'

          @path = path
        end

        def call
          @buffer = StringIO.new(File.read(@path))
          @data   = ::Avro::DataFile::Reader.new(@buffer, ::Avro::IO::DatumReader.new).to_a

          Daru::DataFrame.new(@data)
        end
      end
    end
  end
end
