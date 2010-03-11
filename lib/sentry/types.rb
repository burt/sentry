class ArraySentry < Sentry::Base
  
  def initialize(model, subject, rights, opts = {})
    @model, @subject, @rights, @opts = model, subject, rights, opts
  end
  
  def filter(action)
    model.reject! do |m|
      sentry = Sentry::Factory.new(m, @subject, @opts).create
      !sentry.action_permitted?(action)
    end
  end
  
end