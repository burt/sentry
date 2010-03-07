module Sentry
  class Base

    attr_accessor :model, :subject, :opts

    def initialize(model, subject, opts = {})
      raise ArgumentError, "model cannot be nil" if model.nil?
      raise ArgumentError, "subject cannot be nil" if subject.nil?
      raise ArgumentError, "opts must be a hash" unless opts.is_a?(Hash)
      @model, @subject, @opts = model, subject, opts
      setup
    end
    
    def base_methods
      Sentry::Base.public_instance_methods
    end
    
    def sentry_methods
      public_methods - base_methods
    end
    
    private
    
    def setup
      # @model.define_method
       #@model.instance_variable_set
    end
    
    def add_method
      #def add_method(sentry, name)   
      #  unless sentry.source.respond_to?(name)
      #    sentry.source.class_eval do
      #      puts "::: DEFIING #{name} on #{sentry.source.class}"
      #      define_method name do
      #        sentry.send(name)           
      #      end
      #    end
      #  else
      #    puts "method already defined #{name}"
      #    raise "#{sentry.source} already responds to #{name}!"
      #  end
      #end
    end
    
  end
end