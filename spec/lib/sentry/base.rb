# TODO: dry up each_right assertions

describe Sentry::Base do
  
  describe "a new sentry base" do
    
    before :each do
      @sentry = Sentry::Base.new
    end
    
    it "should have the readers model, subject, rights, options, current_action and enabled" do
      @sentry.should respond_to(:model, :subject, :rights, :options, :enabled)
    end
    
    it "should respond to permitted?, forbidden?, each_right, action_permitted? and right_permitted?" do
      @sentry.should respond_to(:permitted?, :forbidden?, :action_permitted?, :right_permitted?)
    end
    
    it "should not be an authorizer" do
      @sentry.authorizer?.should be_false
    end
    
    it "should not be permitted or forbidden" do
      @sentry.permitted?.should be_false
      @sentry.forbidden?.should be_false
    end
    
    it "should have an empty options hash" do
      @sentry.options.should be_an_instance_of(Hash)
      @sentry.options.should be_empty
    end
    
    it "should have no current action" do
      @sentry.current_action.should be_nil
    end
    
    it "should be enabled" do
      @sentry.enabled.should be_true
    end
    
    describe "with the rights create, read, update and delete" do

      before :each do
        @rights = Sentry.rights do
          create
          read :default => true
          update
          delete
        end
        @sentry.rights = Sentry.rights
      end

      it "should yield the rights create, read, update and delete on each_right" do
        count = 0
        @sentry.each_right do |k, v|
          @rights[k].should == v
          count += 1
        end
        count.should == @rights.size
      end

      describe "before setup" do

        it "should not respond to can_create?, can_read?, can_update? and can_delete?" do
          @sentry.each_right { |k, v| @sentry.should_not respond_to(v.action_name) }
        end

      end

      describe "after setup" do

        before :each do
          @returned = @sentry.setup
        end

        it "should return itself" do
          @returned.should == @sentry
        end

        it "should respond to can_create?, can_read?, can_update? and can_delete?" do
          @sentry.each_right { |k, v| @sentry.should respond_to(v.action_name) }
        end

        it "should not add can_create?, can_read?, can_update? or can_delete? to other instances" do
          @other_sentry = Sentry::Base.new
          @rights.each { |k, v| @other_sentry.should_not respond_to(v.action_name) }
        end
        
        describe "when the can_ methods are called" do
          
          it "should return the default right value" do
            @sentry.each_right { |k, v| @sentry.send(v.action_name).should == v.default }
          end
          
          it "should return true when disabled" do
            @sentry.enabled = false
            @sentry.each_right { |k, v| @sentry.send(v.action_name).should be_true }
          end
          
          it "should return true when permitted" do
            @sentry.stubs(:permitted?).returns(true)
            @sentry.each_right { |k, v| @sentry.send(v.action_name).should be_true }
          end
          
          it "should return false when permitted and forbidden" do
            @sentry.stubs(:permitted?).returns(true)
            @sentry.stubs(:forbidden?).returns(true)
            @sentry.each_right { |k, v| @sentry.send(v.action_name).should be_false }
          end
          
          it "should return false when forbidden" do
            @sentry.stubs(:forbidden?).returns(true)
            @sentry.each_right { |k, v| @sentry.send(v.action_name).should be_false }
          end
          
        end
        
        describe "when the can_ methods are called and the sentry is an authorizer" do
          
          before :each do
            @sentry.options[:authorize] = true
          end
          
          it "should raise Sentry::NotAuthorized when the action is false by default" do
            @sentry.each_right do |k, v|
              unless v.default
                lambda { @sentry.send(v.action_name) }.should raise_error(Sentry::NotAuthorized)
              end
            end
          end
          
          it "should raise Sentry::NotAuthorized when forbidden is true" do
            @sentry.stubs(:forbidden?).returns(true)
            @sentry.each_right { |k, v| lambda { @sentry.send(v.action_name) }.should raise_error(Sentry::NotAuthorized) }
          end
          
          it "should not raise Sentry::NotAuthorized when permitted is true" do
            @sentry.stubs(:permitted?).returns(true)
            @sentry.each_right { |k, v| lambda { @sentry.send(v.action_name) }.should_not raise_error(Sentry::NotAuthorized) }
          end
          
          it "should raise Sentry::NotAuthorized when forbidden is true and permitted is true" do
            @sentry.stubs(:permitted?).returns(true)
            @sentry.stubs(:forbidden?).returns(true)
            @sentry.each_right { |k, v| lambda { @sentry.send(v.action_name) }.should raise_error(Sentry::NotAuthorized) }
          end
          
          it "should not raise Sentry::NotAuthorized when not enabled" do
            @sentry.enabled = false
            @sentry.each_right { |k, v| lambda { @sentry.send(v.action_name) }.should_not raise_error(Sentry::NotAuthorized) }
          end
          
        end

      end

    end
    
  end
  
end