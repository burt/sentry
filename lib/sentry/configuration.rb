module Sentry
  
  class Configuration
    attr_accessor :user_method
    attr_accessor :not_permitted_redirect
    attr_accessor :not_permitted_message
    attr_accessor :enabled
    
    def initialize
      @enabled = true
      @user_method = :current_user
      @not_permitted_redirect = :root_path
      @not_permitted_message = 'You are not permitted to visit this section.'
    end    
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure(&block)
    config = Configuration.new
    yield(config)
    self.configuration = config
  end

end

Sentry.configuration = Sentry::Configuration.new