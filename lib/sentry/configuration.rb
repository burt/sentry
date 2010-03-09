module Sentry 
  
  class Right
    
    attr_reader :default, :actions
    
    def initialize(opts)
      @default = opts[:default] || false
      @actions = opts[:actions]
    end
    
  end
  
  class Configuration
    attr_accessor :user_method
    
    def rights(&block)
      if block_given?
        @rights = {}
        self.instance_eval(&block)
      else
        @rights
      end
    end
    
    def method_missing(sym, *args, &block)
      @rights[sym] = Right.new(args.extract_options!)
    end
    
    #def to_hash
    # returning Hash.new do |h|
    #    [:user_method, :rights].each { |m| h[m] = self.send(m) }
    #  end
    #end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure(&block)
    returning Configuration.new do |c|
      self.configuration = c
      c.instance_eval(&block) if block_given?
    end
  end

end

Sentry.configure do
  user_method = 'current_user'
  rights do
    create :actions => [:new, :create]
    read :actions => [:index, :show]
    update :actions => [:edit, :update]
    delete :actions => [:destroy]
  end
end

puts "Rights:"
puts Sentry.configuration.rights.inspect
puts ""

__END__

Sentry.configure do
  
  user_method = 'current_user'
  # rights = [:create, :read, :update, :delete]
  
  rights do
    create :actions => [:new, :edit]
    read :actions => [:index, :show], :default => true
    update
    delete
  end
  
end
