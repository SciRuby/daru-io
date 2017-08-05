require 'daru'
require 'daru/io/link'

module Daru
  module IO
    class Base
      def optional_gem(dependency, version=nil, requires: nil,
        callback: self.class.name)
        gem dependency, version
        require requires || dependency
      rescue LoadError
        version = version.nil? ? '' : "#{version} version"
        raise LoadError,
          "Please install the #{dependency} gem #{version}, "\
          "or add it to the Gemfile to use the #{callback} module."
      end
    end
  end
end
