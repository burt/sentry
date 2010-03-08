module Sentry 
   
  class Configuration
    attr_accessor :user_method
    attr_accessor :rights
    
    def initialize
      @user_method = 'current_user'
      @rights = {}
    end
    
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure(&block)
    returning Configuration.new do |c|
      self.configuration = c
      c.instance_eval(&block)
    end
  end
  
end