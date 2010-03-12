module Sentry
  module Rails
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.rescue_from Sentry::NotAuthorized, :with => :user_not_authorized
    end
    
    def initialize
      super
      instance = self
      # TODO: rspec
      # TODO: check the values aren't already defined 
      Sentry.rights.each do |k, v|
        (class << self; self; end).class_eval do
          define_method(v.action_name) do |model, *args|
            sentry = Sentry::Factory.new(model, sentry_user, args.extract_options!).create
            sentry.send(v.action_name)
          end
        end
        self.class.send :helper_method, v.action_name
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
      
      def authorize(callback, options = {})
        before_filter(callback, options.merge(:authorize => true)) do |sentry, controller|
          sentry.action_permitted?(controller.action_name)
        end
      end
      
      def filter(callback, options = {})
        before_filter(callback, options) do |sentry, controller|
          sentry.filter(controller.action_name) 
        end
      end
      
      private
      
      def before_filter(callback, options)
        @klass.before_filter(options) do |controller|
          run_finder(controller, options[:after]) unless options[:after].nil?  
          model = controller.instance_variable_get("@#{callback}".to_sym)
          user = controller.sentry_user
          sentry = Sentry::Factory.new(model, user, options).create
          yield sentry, controller
        end
      end
      
      def run_finder(controller, method)
        controller.send(method, true) 
      end
      
    end
      
  end
end