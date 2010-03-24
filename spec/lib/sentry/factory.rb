describe Sentry::Factory do
  
  describe "at construction" do
  
    it "should raise Sentry::ModelNotFound given no model" do
      lambda { Sentry::Factory.new(nil, {}, {}) }.should raise_error(Sentry::ModelNotFound)
    end
  
    it "should raise Sentry::SubjectNotFound given no subject" do
      lambda { Sentry::Factory.new({}, nil, {}) }.should raise_error(Sentry::SubjectNotFound)
    end
  
    it "should raise an argument error if options isn't a hash" do
      lambda { Sentry::Factory.new({}, {}, 1) }.should raise_error(ArgumentError)
    end
  
    it "should not raise an argument error given valid arguments" do
      lambda { Sentry::Factory.new({}, {}) }.should_not raise_error
      lambda { Sentry::Factory.new({}, {}, {}) }.should_not raise_error
    end

    it "should raise Sentry::MissingRights if the singleton rights are empty or nil" do
      Sentry.stubs(:rights).returns(nil)
      Sentry.rights.should be_nil
      lambda { Sentry::Factory.new({}, {}, {}) }.should raise_error(Sentry::MissingRights)
      Sentry.rights {}
      Sentry.stubs(:rights).returns({})
      Sentry.rights.should_not be_nil
      Sentry.rights.should be_empty
      lambda { Sentry::Factory.new({}, {}, {}) }.should raise_error(Sentry::MissingRights)
    end
    
  end

  describe "the Sentry module" do
    
    it "should create a new sentry instance on create" do
      @model = Mocks::Post.make
      @subject = mock
      @sentry = Sentry.create(@model, @subject)
      @sentry.should be_an_instance_of Mocks::PostSentry
      @sentry.model.should == @model
      @sentry.subject.should == @subject
    end

  end

  describe "a new factory" do

    describe "with a model of type Mocks::Post" do

      before :each do
        @subject = mock
        @model = Mocks::Post.make  
        @factory = Sentry::Factory.new(@model, @subject)  
      end

      it "should return a sentry with the same enabled status as the singleton configuration on create" do
        Sentry.configuration.enabled = true
        @factory.create.enabled.should be_true
        Sentry.configuration.enabled = false
        @factory.create.enabled.should be_false
      end

      it "should return a sentry with the same rights as the singleton configuration on create" do
        @factory.create.rights.should == Sentry.rights
      end

      describe "and no options" do
      
        it "should return an instance of Mocks::PostSentry on create" do
          @factory.create.should be_an_instance_of Mocks::PostSentry
          @factory.create.model.should == @model
          @factory.create.subject.should == @subject
        end

      end

      describe "and the class option set to Mocks::PostSentry2" do
        
        before :each do
          @options = {:sentry => 'Mocks::PostSentry2'}
          @factory = Sentry::Factory.new(@model, @subject, @options)
        end
        
        it "should return an instance of Specs::PostSentry2 on create" do
          @factory.create.should be_an_instance_of Mocks::PostSentry2
          @factory.create.model.should == @model
          @factory.create.subject.should == @subject
        end
    
      end

    end

    it "should raise Sentry::SentryNotFound when the corresponding sentry class does not exist" do
      @factory = Sentry::Factory.new(Mocks::ModelWithNoSentry.new, mock)
      lambda { @factory.create }.should raise_error(Sentry::SentryNotFound)
    end
    
    it "should raise Sentry::InvalidSentry when the corresponding sentry class does not inherit from Sentry::Base" do
      @factory = Sentry::Factory.new(mock, mock, :sentry => 'Mocks::BadSentry')
      lambda { @factory.create }.should raise_error(Sentry::InvalidSentry)
    end

  end

end
