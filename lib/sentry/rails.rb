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
          define_method(v.method_name) do |model|
            sentry = Sentry::Factory.new(model, sentry_user, :rights => {k => v}).create
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
      
      def authorize(callback, opts = {})
        before_filter(callback, opts.merge(:authorize => true)) do |sentry, controller|
          sentry.action_permitted?(controller.action_name)
        end
      end
      
      def filter(callback, opts = {})
        before_filter(callback, opts) do |sentry, controller|
          #sentry.action_permitted?(controller.action_name)
          puts "::>>> before_filter called #{callback}"
          # sentry.filter_action(controller.action_name)
        end
      end
      
      private
      
      def before_filter(callback, opts)
        @klass.before_filter(opts) do |controller|
          model = controller.send(callback.to_sym)
          user = controller.sentry_user
          sentry = Sentry::Factory.new(model, user, opts).create
          yield sentry, controller
        end
      end
      
    end
      
  end
end