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
      redirect_to Sentry.configuration.not_permitted_redirect and return
    end
    
    def sentry_user
      self.send Sentry.configuration.user_method
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
          sentry = Sentry::Factory.new(model, subject, opts.merge(:authorize => true)).create
          puts "::: ok so are we allowed???"
          # validate = [*opts[:validate]] || []
          # validate.each { |m| sentry.send("can_#{m}?") }
        end
      end
      
    end 
      
  end
end