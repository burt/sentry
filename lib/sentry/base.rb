module Sentry
  class Base

    attr_accessor :model, :subject, :rights, :options, :enabled, :current_method
    
    def initialize
      @enabled = true
      @options = {}
    end
    
    def authorizer?
      @options[:authorize] == true
    end
    
    def permitted?; false; end
    
    def forbidden?; false; end
    
    def action_permitted?(action)
      rights_with_action(action).all? { |r| self.right_permitted?(r) }
    end
    
    def rights_with_action(action)
      rights.values.select { |r| r.has_action?(action.to_sym) || r.name == action.to_sym }.uniq
    end
    
    def right_permitted?(right)
      self.send(right.method_name)
    end
    
    def each_right
      unless rights.nil?
        rights.each do |k, v|
          yield(k, v)
        end
      end
    end
    
    def setup
      instance = self
      each_right do |k, v|
        (class << self; self; end).class_eval do
          method = v.method_name
          
          define_method(method) { v.default } unless instance.respond_to?(method)
          
          alias_name = "old_#{method}"
          alias_method alias_name, method
          define_method(method) do
            
            instance.current_method = v.name

            permitted = if !instance.enabled
              true
            elsif instance.forbidden?
              false
            elsif instance.permitted?
              true
            else
              instance.send(alias_name)
            end

            if instance.authorizer? && !permitted
              raise Sentry::NotAuthorized, "Not permitted! [model=#{model}, subject=#{subject}]"
            end
            
            permitted
          end
        end
      end
      self
    end
    
  end
end
