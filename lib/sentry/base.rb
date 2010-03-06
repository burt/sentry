module Sentry
  
  class Base

    attr_accessor :model, :subject, :opts

    def initialize(model, subject, opts = {})
      raise ArgumentError, "model cannot be nil" if model.nil?
      raise ArgumentError, "subject cannot be nil" if subject.nil?
      raise ArgumentError, "opts must be a hash" unless opts.is_a?(Hash)
      @model, @subject, @opts = model, subject, opts
    end
    
    def self.base_methods
      Sentry::Base.public_instance_methods
    end
    
    def self.sentry_methods
      self.public_instance_methods - self.base_methods
    end
    
  end

end