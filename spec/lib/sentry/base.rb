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

      it "should not respond to can_create?, can_read?, can_update? and can_delete?" do
        @sentry.each_right { |k, v| @sentry.should_not respond_to(v.action_name) }
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
          
          it "should return the default value for the corresponding right" do
            @sentry.each_right { |k, v| @sentry.send(v.action_name).should == v.default }
          end

          it "should execute the appropriate can on a call to right_permitted?" do
            @sentry.each_right { |k, v| @sentry.right_permitted?(v).should == v.default }
          end
          
          it "should return true when disabled" do
            @sentry.enabled = false
            @sentry.each_right { |k, v| @sentry.should permit(v.action_name) }
          end
          
          it "should return true when permitted" do
            @sentry.stubs(:permitted?).returns(true)
            @sentry.each_right { |k, v| @sentry.should permit(v.action_name) }
          end

          it "should return false when forbidden" do
            @sentry.stubs(:forbidden?).returns(true)
            @sentry.each_right { |k, v| @sentry.should_not permit(v.action_name) }
          end
          
          it "should return false when permitted and forbidden" do
            @sentry.stubs(:permitted?).returns(true)
            @sentry.stubs(:forbidden?).returns(true)
            @sentry.each_right { |k, v| @sentry.should_not permit(v.action_name) }
          end   
          
          it "should raise Sentry::NotAuthorized when the method is not_permitted and the sentry is an authorizer" do
            @sentry.options[:authorize] = true
            @sentry.each_right do |k, v|  
              @sentry.should_not permit(v.action_name) unless v.default
            end
          end

        end

      end
    end
    
  end

  describe "a mock post sentry given the rights create, read, update and delete" do

    before :each do
      @sentry = Mocks::PostSentry.new
      @rights = Sentry.rights { create; read :default => true; update; delete }
      @sentry.rights = @rights
    end

    it "should extend Sentry::Base" do
      @sentry.should be_an_kind_of(Sentry::Base)
    end

    it "should respond_to all cans except can_read?" do
      @sentry.rights.delete(:read)
      @sentry.rights.each { |k, v| @sentry.should respond_to(v.action_name) }
      @sentry.should_not respond_to(:can_read?)
    end

    describe "after setup" do

      before :each do
        @sentry.setup
      end

      it "should respond to all can_ methods" do
        @sentry.each_right { |k, v| @sentry.should respond_to(v.action_name) }
      end

      it "should permit can_create?" do
        @sentry.should permit(:can_create?)
        @sentry.options[:authorize] = true
        @sentry.should permit(:can_create?)
      end

      it "should permit can_read?" do
        @sentry.should permit(:can_read?)
        @sentry.options[:authorize] = true
        @sentry.should permit(:can_read?)
      end

      it "should permit can_update?" do
        @sentry.should permit(:can_update?)
        @sentry.options[:authorize] = true
        @sentry.should permit(:can_update?)
      end

      it "should not permit can_delete?" do
        @sentry.should_not permit(:can_delete?)
        @sentry.options[:authorize] = true
        @sentry.should_not permit(:can_delete?)
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
     
    end

  end

  describe "a mock post sentry given the nested rights create [new, create], read [show, index], update [edit, update] and delete [destroy]" do

    before :each do
      @sentry = Mocks::PostSentry.new
      @rights = Sentry.rights do
        create do
          new
          create
        end
        read :default => true do
          show
          index
        end
        update do
          edit
          update
        end
        delete do
          destroy
        end
      end
      @sentry.rights = @rights
      @sentry.setup
    end

    it "should permit the actions new, create, read, show, index, edit and update" do
      %w{ new create read show index edit update }.each do |w|
        @sentry.should permit_action(w)
      end
    end

    it "should not permit the actions destroy and delete" do
      %w{ destroy delete }.each { |w| @sentry.should_not permit_action(w) }
    end

  end
  
end
