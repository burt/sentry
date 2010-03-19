describe Sentry::Right do
  
  before :each do
    @name = :read
  end
  
  describe "a new right given the name 'read' and no block" do
    
    before :each do
      @right = Sentry::Right.new @name
    end
    
    it "should have the name 'read'" do
      @right.name.should == @name
    end
    
    it "should have the method name 'can_read?'" do
      @right.method_name.should == "can_read?"
    end
    
    it "should have an empty array of actions" do
      @right.actions.should == []
    end
    
    it "should have the default value false" do
      @right.default.should be_false
    end
    
  end
  
  describe "a new right given the name 'read' and a block calling 'actions :index, :show'" do
    
    before :each do
      @right = Sentry::Right.new(@name) { actions :index, :show }
    end
    
    it "should have the actions 'index' and 'show'" do
      actions = [:index, :show]
      @right.actions.should include(*actions)
      actions.each { |a| @right.has_action?(a).should be_true }
    end
    
    it "should not include the action 'read'" do
      @right.actions.should_not include(:read)
      @right.has_action?(:read).should be_false
    end
    
  end
  
  describe "a new right given the name 'read' and a block calling 'default true'" do
    
    before :each do
      @right = Sentry::Right.new(@name) { default true }
    end
    
    it "should have a default value of true" do
      @right.default.should be_true
    end
    
  end
  
  describe "the sentry module" do
    
    it "should respond to rights" do
      Sentry.should respond_to :rights
    end

    it "should have a default set of rights" do
      Sentry.rights.should be_an_instance_of(Hash)
      Sentry.rights.size.should == 4
      [:create, :read, :update, :delete].each { |r| Sentry.rights[r].should be_an_instance_of(Sentry::Right) }
      Sentry.rights[:create].actions.sort.should == [:create, :new]
      Sentry.rights[:read].actions.sort.should == [:index, :show]
      Sentry.rights[:update].actions.sort.should == [:edit, :update]
      Sentry.rights[:delete].actions.sort.should == [:destroy]
    end

    describe "when rights is called with a block" do
      
      before :each do
        @original_rights = Sentry.rights
        @returned = Sentry.rights do
          manage
        end
      end

      it "should return the new rights" do
        pending
      end

      it "should overwrite the rights singleton" do
        pending
      end

      it "should configure the new rights" do
        pending
      end
      
    end
    
  end
  
end
