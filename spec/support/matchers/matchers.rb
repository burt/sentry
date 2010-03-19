# TODO: consolidate shared code in matchers

module Support
  module Matchers

    class Permit

      def initialize(method, authorize = nil, is_action = false)
        @method = method
        @authorize = authorize
        @is_action = is_action
      end

      def matches?(sentry)
        @sentry = sentry
        @sentry.authorize = @authorize unless @authorize.nil?

        begin
          @result = if @is_action
            sentry.action_permitted?(@method)
          else
            sentry.send(@method)
          end
        rescue Sentry::NotAuthorized => e
          @error = e
        end

        if authorizer?
          @error.nil? && @result == true          
        else
          @result == true
        end
      end

      def failure_message_for_should
        returning "expected #{@sentry} to permit #{action_message}'#{@method}'" do |m|
          m << " and not raise Sentry::NotAuthorized" if authorizer?
        end
      end

      def failure_message_for_should_not
        returning "expected #{@sentry} not to permit #{action_message}'#{@method}'" do |m|
          m << " and raise Sentry::NotAuthorized" if authorizer?
        end
      end

      def action_message
        "action " if @is_action
      end

      def authorizer?
        @sentry && @sentry.authorize
      end

    end

    class BeAbleTo

      def initialize(method, model, options = {})
        @method = method
        @model = model
        @options = options
      end

      def matches?(subject)
        @subject = subject
        @sentry = Sentry.create(@model, @subject, @options)

        begin
          @result = @sentry.action_permitted?(@method)
        rescue Sentry::NotAuthorized => e
          @error = e
        end
  
        if authorizer?
          @error.nil? && @result == true          
        else
          @result == true
        end
      end

      def failure_message_for_should
        returning "expected #{@subject.inspect} to be able to #{@method} #{@model}" do |m|
          m << " and not raise Sentry::NotAuthorized" if authorizer?
        end
      end

      def failure_message_for_should_not
        returning "expected #{@subject.inspect} not to be able to #{@method} #{@model}" do |m|
          m << " and raise Sentry::NotAuthorized" if authorizer?
        end
      end

      def authorizer?
        @sentry && @sentry.authorize
      end

    end

    def permit(method, authorize = nil)
      Permit.new(method, authorize)
    end

    def permit_action(action, authorize = nil)
      Permit.new(action, authorize, true)
    end

    def be_able_to(method, model, options = {})
      BeAbleTo.new(method, model, options)
    end

  end
end
