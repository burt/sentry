module Sentry
  
  # TODO: do away with actions and make this a composite pattern??
  
  class Right
    
    attr_reader :name, :default, :actions
    
    def initialize(name, opts)
      @name = name
      @default = opts[:default] || false
      @actions = opts[:actions] || []
    end
    
    def method_name
      "can_#{name}?"
    end
    
  end
  
  class RightsBuilder
    
    def initialize(rights)
      @rights = rights
    end
    
    def method_missing(sym, *args, &block)
      @rights[sym] = Right.new(sym, args.extract_options!)
    end
    
  end
  
  def self.rights(&block)
    if block_given?
      Sentry::RightsBuilder.new(@rights = {}).instance_eval(&block)
    else
      @rights
    end
  end
  
end

Sentry.rights do |r|
  r.create :actions => [:new, :create]
  r.read :actions => [:index, :show]
  r.update :actions => [:edit, :update]
  r.delete :actions => [:destroy]
end