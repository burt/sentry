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
      s = new_sentry
      s.model = model
      s.subject = @subject
      s.authorize = @options[:authorize] == true
      s.enabled = Sentry.configuration.enabled
      s.rights = Sentry.rights
      s.options = @options
      s.setup
    end
    
    # TODO: test passing the sentry class is as well as the name
    # TODO: differentiate between bad instantiation and class not found errors
    def new_sentry
      sentry = begin
        sentry_class = @options[:sentry] || "#{model.class.name}Sentry"
        instantiate(sentry_class)
      rescue => e
        raise Sentry::SentryNotFound, "Sentry '#{sentry_class}' is not defined"
      end
      unless sentry.class.ancestors.include?(Sentry::Base)
        raise Sentry::InvalidSentry, "Sentry '#{sentry_class}' does not extend Sentry::Base"
      end
      sentry
    end
    
    def model
      instantiate(@model)
    end
    
    def instantiate(klass)
      case klass
        when String, Symbol
          klass.to_s.constantize.new
        when Class
          klass.new
        else
          klass
      end
    end
    
  end

  def self.create(model, subject, options = {})
    Sentry::Factory.new(model, subject, options).create
  end

end
