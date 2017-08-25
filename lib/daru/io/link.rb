module Daru
  class DataFrame
    class << self
      def register_io_module(function, instance=nil, &block)
        return define_singleton_method(function, &block) if block_given?

        case function.to_s
        when /\Ato_.*_string\Z/, /\Ato_/, /\Awrite_/ then register_exporter(function, instance)
        when /\Afrom_/, /\Aread_/                    then register_importer(function, instance)
        else raise ArgumentError, 'Invalid function name given to monkey-patch into Daru::DataFrame.'
        end
      end

      private

      def register_exporter(function, instance)
        define_method(function) do |*args, &io_block|
          case function.to_s
          when /\Ato_.*_string\Z/ then instance.new(self, *args, &io_block).to_s
          when /\Ato_/            then instance.new(self, *args, &io_block).to
          when /Awrite_/          then instance.new(self, *args[1..-1], &io_block).write(*args[0])
          end
        end
      end

      def register_importer(function, instance)
        define_singleton_method(function) do |*args, &io_block|
          case function.to_s
          when /\Afrom_/ then instance.new(*args[1..-1], &io_block).from(*args[0])
          when /\Aread_/ then instance.new(*args[1..-1], &io_block).read(*args[0])
          end
        end
      end
    end
  end
end
