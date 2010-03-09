module Sentry
  module Rails
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.rescue_from Sentry::NotAuthorized, :with => :user_not_authorized
    end
    
    def initialize
      super
      instance = self
      # TODO: rspec check the values aren't already defined 
      Sentry.configuration.rights.each do |k, v|
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
      
      def authorize(callback, opts = {})
        self.before_filter(opts) do |controller|
          model = if callback.is_a?(Proc)
            controller.instance_eval &callback
          else
            controller.send(callback.to_sym)
          end
          user = controller.sentry_user
          sentry = Sentry::Factory.new(model, user, opts.merge(:authorize => true)).create
          sentry.action_permitted?(controller.action_name)
        end
      end
      
    end 
      
  end
end