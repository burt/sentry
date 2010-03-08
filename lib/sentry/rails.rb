module Sentry
  module Rails
      
    def self.included(base)
      base.send :extend, ClassMethods
    end
    
    module ClassMethods
      
      def authorize(&block)
        FilterBuilder.new(self).instance_eval(&block)
      end
      
    end
    
    class FilterBuilder

      def initialize(klass)
        @klass = klass
      end

      def method_missing(sym, *args, &block)
        opts = args.extract_options!
        @klass.after_filter opts do |controller|
          puts "running after filter :: #{sym}"
          begin
            model = controller.instance_variable_get("@#{args[0]}")
            # PALM ALL THIS OFF TO THE FACTORY AND WRAP IT IN A BEGIN RESCUE
            unless model.nil?
              sentry = "#{model.class.name}Sentry".constantize.new(model, controller.current_user, opts)
              permitted = sentry.send sym.to_s.gsub('?', '!')
              puts "Permitted ::> #{permitted.inspect}"
            else
              puts "model not found!"
            end
          rescue
          end
        end
      end

    end
      
  end
end