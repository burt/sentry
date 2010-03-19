module Sentry

  class Right

    attr_accessor :name

    def initialize(name, &block)
      @name = name
      @actions = []
      @default = false
      self.instance_eval(&block) if block_given?
    end
    
    def method_name
      "can_#{name}?"
    end
    
    def has_action?(action)
      @actions.include?(action)
    end
    
    def actions(*args)
      args.empty? ? @actions : @actions = args
    end
    
    def default(*args)
      args.empty? ? @default : @default = args[0]
    end
    
  end
  
  class RightsBuilder

    attr_reader :rights

    def initialize
      @rights = {}
    end

    def method_missing(sym, *args, &block)
      @rights[sym] = Sentry::Right.new(sym, &block)
      self
    end

  end

  class << self
    attr_accessor :rights
  end

  def self.rights(&block)
    if block_given?
      @rights = Sentry::RightsBuilder.new.instance_eval(&block).rights
    else
      @rights
    end
  end

end

Sentry.rights do
  create do
    actions :new, :create
  end
  read do
    actions :index, :show
  end
  update do
    actions :edit, :update
  end
  delete do
    actions :destroy
  end
end
