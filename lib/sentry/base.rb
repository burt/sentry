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
      rights.children_with_matching_descendents(action).all? do |r|
        self.right_permitted?(r)
      end
    end
    
    def right_permitted?(right)
      self.send(right.action_name)
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
          method = v.action_name
          
          define_method(method) { v.default } unless instance.respond_to?(method)
          
          alias_name = "old_#{method}"
          alias_method alias_name, method
          define_method(method) do
            
            instance.current_method = v.action

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
