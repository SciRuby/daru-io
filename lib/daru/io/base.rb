require 'daru'

module Daru
  module IO
    class Base
      def optional_gem(dependency, version=nil, requires: nil)
        gem dependency, version
        require requires || dependency
      rescue LoadError
        statement =
          if version.nil?
            "gem install #{dependency}"
          else
            "gem install #{dependency} -v '#{version}'"
          end
        raise LoadError,
          "Please install the #{dependency} gem #{version} version, "\
          "with #{statement} to use the required daru-io Importer / Exporter."
      end
    end
  end
end
