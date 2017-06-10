module Daru
  class DataFrame
    class << self
      def register_io_module(function, instance)
        if function.to_s.include? 'to'
          define_method(function) { |*args| instance.new(self, *args).call }
        else
          define_singleton_method(function) { |*args| instance.new(*args).call }
        end
      end

      def register_all_io_modules
        [Daru::IO::Importers, Daru::IO::Exporters].each do |mod|
          klasses = mod.constants.select { |c| mod.const_get(c).is_a? Class }
          klasses.each do |klass|
            prefix = mod.name.include?('Importers') ? 'from_' : 'to_'
            method = (prefix + klass.downcase).to_sym
            register_io_module method, Object.const_get("#{mod.name}::#{klass}")
          end
        end
      end
    end
  end
end
