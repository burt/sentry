# TODO: remove duplicate in can_ method name creation

module Sentry
  module Rails
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.rescue_from Sentry::NotAuthorized, :with => :user_not_authorized
    end
    
    def initialize
      super
      instance = self
      # TODO: check the values aren't already defined
      
      Sentry.configuration.rights.each do |r|
        method_name = "can_#{r}?"
        metaclass.class_eval do
          define_method(method_name) do |model|
            sentry = Sentry::Factory.new(model, instance.current_user, :rights => [r]).create
            sentry.send(method_name)
          end
        end
        self.class.send :helper_method, method_name
      end
    end

    def user_not_authorized
      flash[:error] = "You don't have access to this section."
      # redirect_to(:back) and return
      redirect_to root_path and return
    end
    
    module ClassMethods
      
      def auth_filter(callback, opts = {})
        self.before_filter(opts) do |controller|
          model = if callback.is_a?(Proc)
            controller.instance_eval &callback
          else
            controller.send(callback.to_sym)
          end
          subject = controller.current_user
          sentry = Sentry::Factory.new(model, subject, opts.merge(:raise => true)).create
          validate = [*opts[:validate]] || []
          validate.each { |m| sentry.send("can_#{m}?") }
        end
      end
      
    end 
      
  end
end