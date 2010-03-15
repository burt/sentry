class ArraySentry < Sentry::Base
  
  def filter(action)
    model.reject! do |m|
      sentry = Sentry.build(m, @subject, @options)
      !sentry.action_permitted?(action)
    end
  end
  
end
