module Sentry
  module Rails
    module Authorisation
      
      def initialize
        super
        alias_action_methods
      end
      
      def self.included(base)
        unless base.respond_to?(:sentry_filters)
          base.send :class_inheritable_accessor, :sentry_filters
          base.sentry_filters = []
        end
        base.rescue_from Sentry::NotAuthorized, :with => :not_authorized
        base.extend ClassMethods
      end

      def not_authorized
        flash[:error] = Sentry.configuration.not_permitted_message 
        path = Sentry.configuration.not_permitted_redirect
        redirect_to path
        return
      end
    
      def sentry_user
        self.send Sentry.configuration.user_method
      end
      
      private  
      
      def alias_action_methods
        controller = self
        (class << self; self; end).class_eval do
          Sentry.rights.each do |k, v|
            v.actions.each do |action|
              if controller.respond_to?(action)
                alias_name = "sentry_old_#{action}"
                alias_method alias_name, action
                define_method(action) do
                  run_filters_for_action(action)
                  send(alias_name)
                end
              end
            end
          end
        end
      end
      
      def run_filters_for_action(action)
        unless self.sentry_filters.empty?
          filters = self.sentry_filters.select { |f| f.actions.include?(action) }
          filters = filters.max_by_field(:level).max_by_field(:precedence)
          filters.each { |f| f.run(action, self) }
        end
      end
    
      module ClassMethods
        
        def self.extended(base)
          add_helper_methods(base)
        end
        
        def sentry(sentry = nil, &block)
          Sentry::Rails::FilterBuilder.new(self, sentry).instance_eval(&block)
        end
        
        private
        
        def self.add_helper_methods(base)
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
        
      end
      
    end
  end
end