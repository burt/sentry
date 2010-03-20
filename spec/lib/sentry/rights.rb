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
      Sentry.rights[:create].actions.map(&:to_s).sort.should == %w{ create new }
      Sentry.rights[:read].actions.map(&:to_s).sort.should == %w{ index show }
      Sentry.rights[:update].actions.map(&:to_s).sort.should == %w{ edit update }
      Sentry.rights[:delete].actions.map(&:to_s).sort.should == %w{ destroy }
    end

    describe "when rights is called with a block" do
      
      before :each do
        @original_rights = Sentry.rights
        @returned = Sentry.rights do
          view; add; delete; edit
        end
      end

      it "should return the new rights" do
        @returned.should_not == @original_rights
        @returned.should be_an_instance_of(Hash)  
        
        @returned.size.should == 4
      end

      it "should overwrite the rights singleton" do
        Sentry.rights.should_not == @original_rights
        Sentry.rights.should == @returned
      end

      it "should configure the new rights" do
        %w{ view add delete edit }.each { |i| @returned[i.to_sym].should be_an_instance_of(Sentry::Right) }
      end
      
    end
    
  end
  
end
