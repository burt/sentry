module Sentry
  class Factory
    
    def initialize(model, subject, opts = {})
      raise Sentry::ModelNotFound, "model cannot be nil" if model.nil?
      raise Sentry::SubjectNotFound, "subject cannot be nil" if subject.nil?
      raise ArgumentError, "opts must be a hash" unless opts.is_a?(Hash)
      @model, @subject, @opts = model, subject, opts
    end
    
    def create
      returning sentry_class.new do |s|
        s.model = @model
        s.subject = @subject
        s.opts = @opts
        s.enabled = Sentry.configuration.enabled
        s.rights = Sentry.rights
        s.apply_methods
      end
    end
    
    def sentry_class
      klass = begin
        sentry_class_name.constantize
      rescue => e
        raise Sentry::SentryNotDefined, "Sentry '#{sentry_class_name}' is not defined"
      end
      unless klass.ancestors.include?(Sentry::Base)
        raise Sentry::InvalidSentry, "Sentry '#{sentry_class_name}' does not extend Sentry::Base"
      end
      klass
    end
    
    def sentry_class_name
      @opts[:class].nil? ? "#{@model.class.name}Sentry" : @opts[:class].to_s
    end
    
  end
end