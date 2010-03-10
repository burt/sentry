module Sentry
  class Base

    attr_accessor :model, :subject, :rights

    def initialize(model, subject, rights, opts = {})
      @model, @subject, @rights, @opts = model, subject, rights, opts
      apply_methods
    end
    
    def action_permitted?(action)
      r = rights.values.select {|r| r.actions.include?(action.to_sym) }
      r.all? { |r| right_permitted?(r) }
    end
    
    def right_permitted?(right)
      self.send right.method_name
    end
    
    def authorizer?
      @opts[:authorize] == true
    end
    
    protected
    
    # TODO: test and comment!
    # TODO: test these aren't added to other instances
    # TODO: test the subclass methods don't get overwritten
    def apply_methods
      instance = self
      Sentry.rights.each do |k, v|
        (class << self; self; end).class_eval do
          method = v.method_name
          
          define_method(method) { v.default } unless instance.respond_to?(method)
          
          alias_name = "old_#{method}"
          alias_method alias_name, method
          define_method method do
            returning self.send(alias_name) do |permitted|
              if instance.authorizer? && !permitted
                raise Sentry::NotAuthorized, "Not permitted! [model=#{model}, subject=#{subject}]"
              end
            end
          end
        end
      end
    end
    
  end
end