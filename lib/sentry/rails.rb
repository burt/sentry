# TODO: rspec

module Sentry
  module Rails
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.rescue_from Sentry::NotAuthorized, :with => :user_not_authorized
    end
    
    def initialize
      super
      instance = self
      # TODO: check the methods aren't already defined 
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

    def user_not_authorized
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
      
      def authorize(opts)
        before_filter(opts.merge!(:authorize => true)) do |sentry, controller|
          sentry.action_permitted?(controller.action_name)
        end
      end
      
      def filter(opts)
        before_filter(opts) do |sentry, controller|
          sentry.filter(controller.action_name) if sentry.respond_to? :filter
        end
      end
      
      private
      
      # TODO: raise if bad params passed
      def before_filter(opts = {})
        @klass.before_filter(opts) do |controller|
          model = if opts[:with].is_a?(Proc)
            controller.instance_eval(&opts[:with])
          else
            controller.instance_variable_get("@#{opts[:with]}".to_sym)
          end 
          puts "model #{model.inspect}"
          user = controller.sentry_user
          sentry = Sentry.create(model, user, opts)
          yield sentry, controller
        end
      end
      
      def run_finder(controller, method)
        controller.send(method, true) 
      end
      
    end
      
  end
end
