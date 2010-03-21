module Sentry
  class Factory
    
    def initialize(model, subject, options = {})
      raise Sentry::ModelNotFound, "model cannot be nil" if model.nil?
      raise Sentry::SubjectNotFound, "subject cannot be nil" if subject.nil?
      raise ArgumentError, "options must be a hash" unless options.is_a?(Hash)
      raise Sentry::MissingRights, "rights are nil or empty" if Sentry.rights.nil? || Sentry.rights.empty?
      @model, @subject, @options = model, subject, options
    end
    
    def create
      s = sentry_class.new
      s.model = model
      s.subject = @subject
      s.authorize = @options[:authorize] == true
      s.enabled = Sentry.configuration.enabled
      s.rights = Sentry.rights
      s.setup
    end
    
    def sentry_class
      klass = begin
        sentry_class_name.constantize
      rescue => e
        raise Sentry::SentryNotFound, "Sentry '#{sentry_class_name}' is not defined"
      end
      unless klass.ancestors.include?(Sentry::Base)
        raise Sentry::InvalidSentry, "Sentry '#{sentry_class_name}' does not extend Sentry::Base"
      end
      klass
    end
    
    def sentry_class_name
      @options[:class].nil? ? "#{model.class.name}Sentry" : @options[:class].to_s
    end
    
    def model
      @model.is_a?(String) || @model.is_a?(Symbol) ? @model.to_s.constantize.new : @model
    end
    
  end

  def self.create(model, subject, options = {})
    Sentry::Factory.new(model, subject, options).create
  end

end
