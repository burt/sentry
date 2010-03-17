# TODO: rspec
# TODO: raise bad params
# TODO: check controllers don't already define methods

module Sentry
  module Rails
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.rescue_from Sentry::NotAuthorized, :with => :not_authorized
    end
    
    def initialize
      super
      instance = self
      Sentry.rights.each do |k, v|
        (class << self; self; end).class_eval do
          define_method(v.method_name) do |model, *args|
            sentry = Sentry.create(model, sentry_user, args.extract_options!)
            sentry.send(v.method_name)
          end
        end
        self.class.send :helper_method, v.method_name
      end
    end

    def not_authorized
      flash[:error] = Sentry.configuration.not_permitted_message
      redirect_to Sentry.configuration.not_permitted_redirect.to_s
      return
    end
    
    def sentry_user
      self.send Sentry.configuration.user_method
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
        before_filter(*args) do |sentry, controller|
          sentry.options.merge!(:authorize => true)
          sentry.action_permitted?(controller.action_name)
        end
      end
      
      def filter(*args)
        before_filter(*args) do |sentry, controller|
          sentry.filter(controller.action_name) if sentry.respond_to? :filter
        end
      end
      
      private
      
      def before_filter(*args)    
        opts = prep_filter_options(*args)
        @klass.before_filter(opts) do |controller|
          model = get_model(controller, opts)
          user = controller.sentry_user
          sentry = Sentry.create(model, user, opts)
          yield sentry, controller
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
