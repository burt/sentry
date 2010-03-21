class ArraySentry < Sentry::Base
  
  def filter(action, options = {})
    member_options = options.clone
    member_options[:sentry] = options[:member_sentry]
    model.reject! do |m|
      !Sentry.create(m, @subject, member_options).action_permitted?(action)
    end
  end
  
end
