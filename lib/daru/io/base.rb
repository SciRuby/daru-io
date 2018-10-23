require 'daru'
require 'daru/io/link'

module Daru
  module IO
    # Base IO Class that contains generic helper methods, to be
    # used by other {Importers::Base} and {Exporters::Base} via inheritence
    class Base
      # Specifies and requires a gem, if the gem is present in the application
      # environment. Else, raises `LoadError` with meaningful message of which
      # dependency to install for which Daru-IO module.
      #
      # @param dependency [String] A dependency to specify with `gem` command
      # @param version [String] A version range to specify with `gem` command
      # @param requires [String] The gem name to be required, in case it's
      #   different from the dependency name. For example, activerecord
      #   dependency has to be required as `require 'active_record'`
      # @param callback [Class] The Daru-IO module which is being used currently.
      #   Useful for throwing meaningful `LoadError` message.
      #
      # @example Requires with dependency
      #   optional_gem 'avro'
      #   #=> true
      #
      # @example Requires with version and requires
      #   optional_gem 'activerecord', '>= 4.0', requires: 'active_record'
      #   #=> true
      #
      # @example Raises error with meaningful message
      #   df = Daru::DataFrame.from_json('path/to/file.json')
      #   #=> LoadError: Please install the jsonpath gem, or add it to the
      #   #   Gemfile to use the Daru::IO::Importers::JSON module.
      def optional_gem(dependency, version=nil, requires: nil,
        callback: self.class.name)
        gem dependency, version
        require requires || dependency
      rescue LoadError
        version = version.nil? ? '' : " #{version} version"
        raise LoadError,
          "Please install the #{dependency} gem#{version}, "\
          "or add it to the Gemfile to use the #{callback} module."
      end
    end
  end
end
