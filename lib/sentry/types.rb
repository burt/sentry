class ArraySentry < Sentry::Base
  
  def filter(action, options = {})
    model.reject! do |m|
      !Sentry.create(m, @subject, options).action_permitted?(action)
    end
  end
  
end
