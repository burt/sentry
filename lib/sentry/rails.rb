module Sentry
  module RailsController
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.rescue_from Sentry::NotAuthorized, :with => :not_authorized
      add_sentry_methods(base)
    end

    def not_authorized
      flash[:error] = Sentry.configuration.not_permitted_message
      redirect_to Sentry.configuration.not_permitted_redirect.to_s
      return
    end
    
    def sentry_user
      self.send Sentry.configuration.user_method
    end
    
    private
    
    def self.add_sentry_methods(base)
      base.instance_eval do
        Sentry.rights.each do |k, v|
          method = v.method_name
          define_method(method) do |model, *args|
            sentry = Sentry.create(model, sentry_user, args.extract_options!)
            sentry.send(method)
          end
          helper_method method
        end
      end
    end
    
    module ClassMethods
      
      def sentry(&block)
        FilterBuilder.new(self).instance_eval(&block)
      end
      
    end
    
    class FilterBuilder
      
      def initialize(klass)
        @klass = klass
      end
      
      def authorize(*args)
        before_filter(*args) do |sentry, controller, options|
          sentry.authorize = true
          sentry.action_permitted?(controller.action_name)
        end
      end
      
      def filter(*args)
        before_filter(*args) do |sentry, controller, options|
          sentry.filter(controller.action_name, options) if sentry.respond_to? :filter
        end
      end
      
      private
      
      def before_filter(*args)
        opts = prep_filter_options(*args)
        @klass.before_filter(opts.clone) do |controller|
          model = get_model(controller, opts)
          user = controller.sentry_user
          sentry = Sentry.create(model, user, opts)
          yield sentry, controller, opts
        end
      end
      
      def get_model(controller, opts)
        model_opt = opts[:with]          
        model = if model_opt.is_a?(Proc)
          controller.instance_eval(&model_opt)
        else
          controller.instance_variable_get("@#{model_opt}")
        end
      end

      def prep_filter_options(*args)
        opts = args.extract_options!
        unless args.size == 0
          actions = if args.include?(:all)
            [:index, :show, :new, :create, :update, :edit, :delete]
          else
            args
          end
          opts.merge!(:only => actions)
          opts.delete(:only) if opts.has_key?(:except)
        end
        opts
      end
      
    end
      
  end
end
