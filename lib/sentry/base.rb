module Sentry
  class Base

    attr_accessor :model, :subject, :rights

    def initialize(model, subject, rights, opts = {})
      @model, @subject, @rights, @opts = model, subject, rights, opts
      apply_methods
    end
    
    protected
    
    def authorize?
      @opts[:authorize] == true
    end
    
    # TODO: test and comment!
    # TODO: test these aren't added to other instances
    # TODO: test the subclass methods don't get overwritten
    def apply_methods
      instance = self
      Sentry.configuration.rights.each do |k, v|
        (class << self; self; end).class_eval do
          method = v.method_name
          
          define_method(method) { v.default_value } unless instance.respond_to?(method)
          
          alias_name = "old_#{method}"
          alias_method alias_name, method
          define_method method do
            returning self.send(alias_name) do |permitted| 
              if instance.authorize? && !permitted
                raise Sentry::NotAuthorized, "Not permitted! [model=#{model}, subject=#{subject}]"
              end
            end
          end
        end
      end
    end
    
  end
end