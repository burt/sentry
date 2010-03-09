module Sentry
  class Base

    attr_accessor :model, :subject

    def initialize(model, subject, opts = {})
      @model, @subject, @opts = model, subject, opts
      
      add_default_auth_methods(self)
      add_raise_aliases(self)
    end
    
    def each_right
      rights.each do |k|
        method_name = "can_#{k}?"
        yield k, method_name
      end
    end
    
    protected
    
    def rights
      @opts[:rights] || []
    end
    
    def raise_not_permitted?
      @opts[:raise] == true
    end
    
    def add_default_auth_methods(instance)
      # TODO: test these aren't added to other instances
      # TODO: test the subclass methods don't get overwritten
      metaclass.class_eval do
        instance.each_right do |k, m|
          define_method(m) { false } unless instance.respond_to?(m)
        end
      end
    end
    
    # TODO: refactor to loop over rights only once
    def add_raise_aliases(instance)
      metaclass.class_eval do
        instance.each_right do |k, m|
          alias_name = "old_#{m}"
          alias_method "old_#{m}", m
          define_method m do
            permitted = self.send alias_name
            if raise_not_permitted? && !permitted
              raise Sentry::NotAuthorized, "Not permitted! [model=#{model}, subject=#{subject}]"
            end
            permitted
          end
        end
      end
    end
    
  end
end