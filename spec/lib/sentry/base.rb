describe Sentry::Base do

  before :each do
    @rights = Sentry.rights
  end

  describe "a new sentry base" do
    
    before :each do
      @sentry = Sentry::Base.new
    end
    
    it "should have the accessors model, subject, rights, authorize, current_right and enabled" do
      @sentry.should respond_to(:model, :subject, :rights, :authorize, :current_right, :enabled)
    end
    
    it "should respond to permitted?, forbidden?, each_right, action_permitted? and right_permitted?" do
      @sentry.should respond_to(:permitted?, :forbidden?, :action_permitted?, :right_permitted?)
    end

    it "should have a nil current_method" do
      @sentry.current_method.should be_nil
    end

    it "should have an empty array of current actions" do 
      @sentry.current_actions.should == []
    end
    
    it "should have authorize set to false" do
      @sentry.authorize.should be_false
    end
    
    it "should not be permitted or forbidden" do
      @sentry.permitted?.should be_false
      @sentry.forbidden?.should be_false
    end
    
    it "should be enabled" do
      @sentry.enabled.should be_true
    end
    
    describe "with the rights create, read, update and delete" do

      before :each do
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

      it "should not respond to can_create?, can_read?, can_update? and can_delete?" do
        @sentry.each_right { |k, v| @sentry.should_not respond_to(v.method_name) }
      end

      describe "after setup" do

        before :each do
          @returned = @sentry.setup
        end

        it "should return itself" do
          @returned.should == @sentry
        end

        it "should respond to can_create?, can_read?, can_update? and can_delete?" do
          @sentry.each_right { |k, v| @sentry.should respond_to(v.method_name) }
        end

        it "should not add can_create?, can_read?, can_update? or can_delete? to other instances" do
          @other_sentry = Sentry::Base.new
          @rights.each { |k, v| @other_sentry.should_not respond_to(v.method_name) }
        end

        describe "when the can_ methods are called" do
          
          it "should return the default value for the corresponding right" do
            @sentry.each_right { |k, v| @sentry.send(v.method_name).should == v.default }
          end

          it "should execute the appropriate can on a call to right_permitted?" do
            @sentry.each_right { |k, v| @sentry.right_permitted?(v).should == v.default }
          end
          
          it "should return true when disabled" do
            @sentry.enabled = false
            @sentry.each_right { |k, v| @sentry.should permit(v.method_name) }
          end
          
          it "should return true when permitted" do
            @sentry.stubs(:permitted?).returns(true)
            @sentry.each_right { |k, v| @sentry.should permit(v.method_name) }
          end

          it "should return false when forbidden" do
            @sentry.stubs(:forbidden?).returns(true)
            @sentry.each_right { |k, v| @sentry.should_not permit(v.method_name) }
          end
          
          it "should return false when permitted and forbidden" do
            @sentry.stubs(:permitted?).returns(true)
            @sentry.stubs(:forbidden?).returns(true)
            @sentry.each_right { |k, v| @sentry.should_not permit(v.method_name) }
          end   
          
          it "should raise Sentry::NotAuthorized when the method is not_permitted and the sentry is an authorizer" do
            @sentry.authorize = true
            @sentry.each_right do |k, v|  
              @sentry.should_not permit(v.method_name) unless v.default
            end
          end

        end

      end

    end
    
  end

  describe "a mock post sentry given the rights create, read, update and delete" do

    before :each do
      @sentry = Mocks::MockSentry.new
      @sentry.rights = @rights
    end

    it "should extend Sentry::Base" do
      @sentry.should be_an_kind_of(Sentry::Base)
    end

    it "should respond_to all cans except can_read?" do
      @sentry.rights.delete(:read)
      @sentry.rights.each { |k, v| @sentry.should respond_to(v.method_name) }
      @sentry.should_not respond_to(:can_read?)
    end

    describe "after setup" do

      before :each do
        @sentry.setup
      end

      it "should respond to all can_ methods" do
        @sentry.each_right { |k, v| @sentry.should respond_to(v.method_name) }
      end

      it "should permit can_create?" do
        @sentry.should permit(:can_create?)
        @sentry.should permit(:can_create?, true)
      end

      it "should permit can_read?" do
        @sentry.should permit(:can_read?)
        @sentry.should permit(:can_read?, true)
      end

      it "should permit can_update?" do
        @sentry.should permit(:can_update?)
        @sentry.should permit(:can_update?, true)
      end

      it "should not permit can_delete?" do
        @sentry.should_not permit(:can_delete?)
        @sentry.should_not permit(:can_delete?, true)
      end

      it "should permit can_delete? when disabled" do
        @sentry.enabled = false
        @sentry.should permit(:can_delete?)
      end

      it "should permit can_delete? when permitted returns true" do
        @sentry.stubs(:permitted?).returns(true)
        @sentry.should permit(:can_delete?)
      end

      it "should not permit can_delete? when forbidden returns true" do
        @sentry.stubs(:forbidden?).returns(true)
        @sentry.should_not permit(:can_delete?)
      end

      it "should not permit can_delete? when permitted and forbidden return true" do
        @sentry.stubs(:permitted?).returns(true)
        @sentry.stubs(:forbidden?).returns(true)
        @sentry.should_not permit(:can_delete?)
      end   
     
      it "should have a nil current_right before and after each can_ call" do
        @sentry.current_right.should be_nil
        @sentry.each_right do |k, v|
          @sentry.right_permitted?(v)
        end
        @sentry.current_right.should be_nil
      end

      it "should have a nil current_method before and after each can_ call" do
        @sentry.current_method.should be_nil
        @sentry.each_right do |k, v|
          @sentry.right_permitted?(v)
        end
        @sentry.current_method.should be_nil
      end

      it "should have an empty array for current_actions before and after each can_ call" do
        @sentry.current_actions.should == []
        @sentry.each_right do |k, v|
          @sentry.right_permitted?(v)
        end
        @sentry.current_actions.should == []
      end

      it "should have the appropriate current_right during each can_ call" do
        pending
      end

      it "should have the appropriate current_method during each can_ call" do
        pending
      end

      it "should have the appropriate current_actions during each can_ call" do
        pending
      end

    end

  end

  describe "a mock post sentry given the nested rights create [new, create], read [show, index], update [edit, update] and delete [destroy]" do

    before :each do
      @sentry = Mocks::MockSentry.new
      @sentry.rights = @rights
      @sentry.setup
    end

    it "should permit the actions new, create, read, show, index, edit and update" do
      %w{ new create read show index edit update }.each do |w|
        @sentry.should permit_action(w)
      end
    end

    it "should not permit the action destroy" do
      @sentry.should_not permit_action(:destroy)
    end

  end

  describe "a Post created by a User named john" do
    
    before :each do
      @john = Mocks::User.make(:name => 'john')
      @paul = Mocks::User.make(:name => 'paul')
      @george = Mocks::User.make(:name => 'george')
      @ringo = Mocks::User.make(:name => 'ringo')
      @users = [@john, @paul, @george, @ringo]
      @post = Mocks::Post.make(:author => @john, :published => false, :new_record => false)
    end

    it "should be creatable by no-one" do
      @users.each { |u| u.should_not be_able_to(:create, @post) }
    end

    it "should be readable by john and ringo" do
      [@john, @ringo].each {|u| u.should be_able_to :read, @post }
      [@paul, @george].each {|u| u.should_not be_able_to :read, @post }
    end

    it "should be updatable by john and ringo" do
      [@john, @ringo].each {|u| u.should be_able_to :update, @post }
      [@paul, @george].each {|u| u.should_not be_able_to :update, @post }
    end

    it "should be deletable by only ringo" do
      @ringo.should be_able_to(:delete, @post)
      @users.delete(@ringo)
      @users.each { |u| u.should_not be_able_to(:delete, @post) }
    end

  end

end
