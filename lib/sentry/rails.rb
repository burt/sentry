unless ActionController::Base.respond_to? :sentry_filters
  ActionController::Base.send :class_inheritable_accessor, :sentry_filters
  ActionController::Base.sentry_filters = []
end

class Class
  
  def superclass_count
    if @count.nil?
      @count, current = -1, self
      until (current = current.superclass).nil?; @count += 1; end
    end
    @count
  end
  
end

class Array
  
  def max_by_field(field)
    return [] if empty?
    max = max { |a, b| a.send(field) <=> b.send(field) }
    select { |i| i.send(field) == max.send(field) }
  end
  
end

module Sentry
  module Rails
    module Authorisation
      
      def self.included(base)
        base.rescue_from Sentry::NotAuthorized, :with => :not_authorized
        add_sentry_methods(base)
        add_before_filter(base)
        base.instance_eval do
          def sentry(sentry = nil, &block)
            Sentry::Rails::Authorisation::FilterBuilder.new(self, sentry).instance_eval(&block)
          end
        end
      end

      def not_authorized
        flash[:error] = Sentry.configuration.not_permitted_message 
        path = Sentry.configuration.not_permitted_redirect
        redirect_to path
        return
      end
    
      def sentry_user
        self.send Sentry.configuration.user_method
      end
      
      private
    
      def self.add_sentry_methods(base)
        base.instance_eval do
          Sentry.rights.each do |k, v|
            method = v.method_name
            define_method(method) do |model, *args|
              sentry = Sentry.create(model, sentry_user, args.extract_options!)
              sentry.send(method)
            end
            helper_method method
          end
        end
      end
      
      def self.add_before_filter(base)
        base.instance_eval do
          before_filter do |controller|
            unless controller.class.sentry_filters.empty?
              action = controller.action_name.to_sym
              filters = controller.class.sentry_filters.select { |f| f.actions.include?(action) }
              filters = filters.max_by_field :level
              filters = filters.max_by_field :precedence
              puts "actions that match:"
              filters.each do |f|
                puts f.inspect
                puts "level=#{f.level}, precedence=#{f.precedence}"
                f.run(action, controller)
              end
            end
          end
        end
      end
      
      def filters_with_max_for_field(filters, field)
        return [] if filters.empty?
        max = filters.max { |a, b| a.send(field) <=> b.send(field) }
        filters.select { |f| f.send(field) == max.send(field) }
      end
    
      class FilterBuilder
      
        def initialize(klass, sentry = nil)
          @klass = klass
          @sentry = sentry
        end
        
        def method_missing(sym, *args, &block)
          filter_class = "Sentry::Rails::Authorisation::#{sym.to_s.capitalize}Filter"
          filter = filter_class.constantize.new(@klass, @sentry, *args, &block)
          @klass.sentry_filters << filter
        end
        
      end
      
      class Filter

        class_inheritable_accessor :precedence
        @@subclass_count = 0

        attr_accessor :klass, :actions

        def initialize(klass, sentry = nil, *args, &block)
          @klass = klass
          @sentry = sentry
          @opts = args.extract_options!
          @opts.reverse_merge!(:sentry => @sentry) unless @sentry.nil?
          @actions = args
          @actions = Sentry.actions if @actions.include?(:all)
          puts "options: #{@opts}"
          puts "actions: #{@actions}"
          # TODO: add excludable actions
        end

        def run(action, controller); end
        
        def level
          @klass.superclass_count
        end
        
        def precedence
          self.class.precedence
        end

        def self.inherited(subclass)
          subclass.precedence = @@subclass_count
          @@subclass_count += 1
        end
        
      end

      class PermitFilter < Sentry::Rails::Authorisation::Filter; end

      class AuthorizeFilter < Sentry::Rails::Authorisation::Filter; 
        
        def run(action, controller)
          puts ">>> run in authorize filter"
          user = controller.sentry_user
          model = get_model(controller, @opts)
          sentry = Sentry.create(model, user, @opts)
          sentry.authorize = true
          sentry.action_permitted?(action)
        end
        
        private
        
        def get_model(controller, opts)
          # TODO: raise if no with
          model = opts[:with]
          case model
            when Proc
              controller.instance_eval(&model)
            when String, Symbol
              if model.to_s.include?("@")
                controller.instance_variable_get(model)
              else
                controller.send(model)
              end
            else
              model
          end
        end
        
      end
      
      class DenyFilter < Sentry::Rails::Authorisation::Filter
        
        def run(action, controller)
          raise Sentry::NotAuthorized, "Not permitted! [action=#{action}, controller=#{controller}]"
        end
        
      end
      
    end
  end
end
