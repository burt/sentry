class ArraySentry < Sentry::Base
  
  def initialize(model, subject, rights, opts = {})
    @model, @subject, @rights, @opts = model, subject, rights, opts
    model.map! { |m| Sentry::Factory.new(m, subject, opts).create }
  end
  
  #def filter(right)
  #  
  #end
  
end