module Sentry
  class Base

    attr_accessor :model, :subject, :opts

    def initialize(model, subject, opts = {})
      @model, @subject, @opts = model, subject, opts
    end
    
  end
end