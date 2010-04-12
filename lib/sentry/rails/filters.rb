module Sentry
  module Rails
    
    class FilterBuilder
    
      def initialize(controller_class, sentry = nil)
        @controller_class = controller_class
        @sentry = sentry
      end
      
      def method_missing(sym, *args, &block)
        filter_class = "Sentry::Rails::#{sym.to_s.capitalize}Filter"
        filter = filter_class.constantize.new(@controller_class, @sentry, *args, &block)
        @controller_class.sentry_filters << filter
      end 
      
    end
    
    class Filter

      class_inheritable_accessor :precedence
      @@subclass_count = 0

      attr_accessor :controller_class, :actions

      def initialize(controller_class, sentry = nil, *args, &block)
        @controller_class = controller_class
        @sentry = sentry
        @opts = args.extract_options!
        @opts.reverse_merge!(:sentry => @sentry) unless @sentry.nil?
        @actions = args
        @actions = Sentry.actions if @actions.include?(:all)
        @actions -= [*@opts[:except]].compact
        @block = block
      end

      def run(action, controller); end
      
      def level
        @controller_class.superclass_count
      end
      
      def precedence
        self.class.precedence
      end

      def self.inherited(subclass)
        subclass.precedence = @@subclass_count
        @@subclass_count += 1
      end
      
    end

    class PermitFilter < Sentry::Rails::Filter; end

    class AuthorizeFilter < Sentry::Rails::Filter; 
      
      def run(action, controller)
        user = controller.sentry_user
        model = get_model(controller)
        sentry = Sentry.create(model, user, @opts)
        sentry.authorize = true
        sentry.action_permitted?(action)
      end
      
      private
      
      def get_model(controller)
        if model = @opts[:with]
          case model
            when Proc
              controller.instance_eval(&model)
            when String, Symbol
              if model.to_s.include?("@")
                controller.instance_variable_get(model)
              else
                controller.send(model)
              end
            else
              model
          end
        elsif @block
          controller.instance_eval(&@block)
        else
          raise "authorize expects a :with option or a block"
        end
      end
      
    end
    
    class DenyFilter < Sentry::Rails::Filter
      
      def run(action, controller)
        raise Sentry::NotAuthorized, "Not permitted! [action=#{action}, controller=#{controller}]"
      end
      
    end
    
  end
end