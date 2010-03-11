module Sentry

  class RightsBuilder

    attr_accessor :root

    def initialize(root = nil)
      @root = root || Right.new("root")
    end

    def method_missing(sym, *args, &block)
      node = Right.new(sym, @root, args.extract_options!)
      RightsBuilder.new(node).instance_eval(&block) if block_given?
      self
    end

  end

  class Right

    attr_reader :action, :parent, :options, :children

    def initialize(action, parent = nil, options = {})
      @children = {}
      @action = action
      @parent = parent
      @parent[action] = self if @parent
      @options = options
    end

    def method_missing(sym, *args, &block)
      @children.send(sym, *args, &block)
    end

    def visit(&block)
      each_value { |v| v.visit(&block) } unless empty?
      block.call(self)
    end

    def matching_descendents(action)
      returning [] do |found|
        visit { |r| found << r if r.action == action.to_sym }
      end
    end

    def children_with_matching_descendents(action)
      matching_descendents(action).map do |r|
        current = r
        while current.parent != self; current = current.parent; end
        current
      end.uniq
    end

    def action_name
      "can_#{action}?"
    end

  end

  def self.rights(&block)
    if block_given?
      @rights = RightsBuilder.new.instance_eval(&block).root
    else
      @rights
    end
  end

end

Sentry.rights do
  
  create do
    new
    create
  end
  
  read do
    index
    show
  end
  
  update do
    edit
    update
  end
  
  delete do
    destroy
  end
  
end


__END__

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