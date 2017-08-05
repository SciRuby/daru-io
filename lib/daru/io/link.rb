module Daru
  class DataFrame
    class << self
      def register_io_module(function, instance=nil, &block)
        return define_singleton_method(function, &block) if block_given?

        if function.to_s.include? 'to'
          define_method(function) { |*args, &io_block| instance.new(self, *args, &io_block).call }
        else
          define_singleton_method(function) { |*args| instance.new(*args).call }
        end
      end

      # @note This method currently isn't used. But if we're planning on make
      #   the linkages part from the user's end, this will turn out to be a
      #   very useful inclusion.
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
