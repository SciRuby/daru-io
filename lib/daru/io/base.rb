module Daru
  module IO
    class Base
      def initialize(binding)
        args = method(__method__).parameters.map do |_, name|
          [name, binding.local_variable_get(name.to_s)]
        end.to_h

        args.each do |k, v|
          instance_variable_set("@#{k}", v)
          define_singleton_method(k) { instance_variable_get("@#{k}") }
        end
      end
    end
  end
end
