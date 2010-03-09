module Sentry
  
  class Configuration
    attr_accessor :user_method
    attr_accessor :not_permitted_redirect
    attr_accessor :not_permitted_message
    
    def rights(&block)
      if block_given?
        Sentry::RightsBuilder.new(@rights = {}).instance_eval(&block)
      else
        @rights
      end
    end
    
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure(&block)
    returning Configuration.new do |c|
      yield(c)
      self.configuration = c
    end
  end

end

Sentry.configure do |c|
  c.user_method = :current_user
  c.not_permitted_redirect = :root_path
  c.not_permitted_message = 'You are not permitted to visit this section.'
  c.rights do
    create :actions => [:new, :create]
    read :actions => [:index, :show]
    update :actions => [:edit, :update]
    delete :actions => [:destroy]
  end
end

puts Sentry.configuration.inspect