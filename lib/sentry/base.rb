module Sentry
  class Base

    attr_accessor :model, :subject, :rights, :authorize, :enabled, :current_right, :options
    
    def initialize
      @enabled = true
      @authorize = false
      @options = {}
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

    def current_method
      current_right.nil? ? nil : current_right.name
    end

    def current_actions
      current_right.nil? ? [] : current_right.actions
    end
    
    def each_right
      unless rights.nil?
        rights.each do |k, v|
          yield(k, v)
        end
      end
    end
    
    def filter
      model.reject! { |m| yield m }
    end
    
    def setup
      instance = self
      each_right do |k, v|
        (class << self; self; end).class_eval do
          method = v.method_name
          define_method(method) { v.default } unless instance.respond_to?(method)
          alias_name = "sentry_old_#{method}"
          alias_method alias_name, method
          define_method(method) { test_permitted(alias_name, v) }
        end
      end
      self
    end
    
    private
    
    def test_permitted(method, right)
      self.current_right = right
      permitted = if !enabled
        true
      elsif forbidden?
        false
      elsif permitted?
        true
      else
        send(method)
      end
      if authorize && !permitted
        raise Sentry::NotAuthorized, "Not permitted! [model=#{self.model}, subject=#{self.subject}]"
      end
      self.current_right = nil
      return permitted
    end
    
  end
end
