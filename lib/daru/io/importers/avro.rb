require 'daru/io/importers/base'

module Daru
  module IO
    module Importers
      # Avro Importer Class, that extends `from_avro` method to `Daru::DataFrame`
      class Avro < Base
        Daru::DataFrame.register_io_module :from_avro, self

        # Imports a `Daru::DataFrame` from an Avro file.
        #
        # @param path [String] Path to Avro file, where the dataframe is to be imported from.
        #
        # @return A `Daru::DataFrame` imported from the given relation and fields
        #
        # @note The 'snappy' gem handles compressions and is used within Avro gem. Yet, it isn't
        #   specified as a dependency in Avro gem. Hence, it has been added separately.
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
