module Sentry
  class Factory
    
    def initialize(model, subject, opts = {})
      raise ArgumentError, "model cannot be nil" if model.nil?
      raise ArgumentError, "subject cannot be nil" if subject.nil?
      raise ArgumentError, "opts must be a hash" unless opts.is_a?(Hash)
      @model, @subject, @opts = model, subject, opts
    end
    
    def create
      sentry_class.new(@model, @subject, @opts)
    end
    
    def sentry_class
      "#{@model.class.name}Sentry".constantize
    end
    
    def sentry_class_name
      @opts[:class].nil? ? "#{@model.class.name}Sentry" : @opts[:class].to_s
    end
    
  end
end