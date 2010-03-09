module Sentry
  
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
  
end