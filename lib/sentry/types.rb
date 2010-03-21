class ArraySentry < Sentry::Base
  
  def filter(action)
    model.reject! { |m| !sentry_for_member(m).action_permitted?(action) }
  end
  
  private
  
  def member_options
    returning options.clone do |o|
      o[:sentry] = options[:member_sentry]
    end
  end
  
  def sentry_for_member(m)
    Sentry.create(m, @subject, member_options)
  end
  
end
