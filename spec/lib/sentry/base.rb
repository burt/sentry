describe Sentry::Base do
  
  before :each do
    @model = mock
    @subject = mock
    @opts = {}
  end
  
  describe "sentry construction" do
  
    it "should raise an argument error given no source" do
      lambda { Sentry::Base.new(nil, {}, {}) }.should raise_error(ArgumentError)
    end
  
    it "should raise an argument error given no subject" do
      lambda { Sentry::Base.new({}, nil, {}) }.should raise_error(ArgumentError)
    end
  
    it "should raise an argument error if opts isn't a hash" do
      lambda { Sentry::Base.new({}, {}, 1) }.should raise_error(ArgumentError)
    end
  
    it "should not raise an argument error given valid arguments" do
      lambda { Sentry::Base.new({}, {}) }.should_not raise_error
      lambda { Sentry::Base.new({}, {}, {}) }.should_not raise_error
    end
    
  end
  
  describe "a valid sentry" do
    
    before :each do
      @sentry = Sentry::Base.new(@model, @subject, @opts)
    end
    
    it "should respond to model, subject and opts" do
      @sentry.should respond_to(:model, :subject, :opts)
    end
    
    it "should return model, subject and opts" do
      @sentry.model.should == @model
      @sentry.subject.should == @subject
      @sentry.opts.should == @opts
    end
    
    it "should respond to base_methods with all Sentry::Base public instance methods" do
      base_methods = @sentry.base_methods
      base_methods.should be_an_instance_of Array
      base_methods.should == Sentry::Base.public_instance_methods
    end
    
    it "should respond to sentry_methods with an empty array" do
      sentry_methods = @sentry.sentry_methods
      sentry_methods.should be_an_instance_of Array
      sentry_methods.should == []
    end
    
  end
  
  describe "a mock sentry (subclass of sentry base)" do
    
    before :each do
      @mock = MockSentry.new(@model, @subject, @opts)
    end
    
    it "should have four sentry_methods" do
      @mock.sentry_methods.size.should == 4
      @mock.sentry_methods.sort.should == %w{ creatable? readable? updatable? deletable? }.sort
    end
    
    it "should define an instance variable '@sentry' on the model, that returns itself" do
      @mock.model.instance_variable_get("@sentry").should == @mock
    end
    
    it "should define an accessor 'sentry' on the model, that returns itself" do
      @mock.model.should respond_to :sentry
      @mock.model.sentry.should == @mock
    end
  
    it "should raise an InvalidSetup error if the model already defines the instance variable '@sentry'" do
      @model.instance_variable_set("@sentry", {})
      lambda { MockSentry.new(@model, @subject, @opts) }.should raise_error(Sentry::InvalidSetup)
    end
  
    it "should raise an InvalidSetup error if the model already defines the accessor 'sentry'" do
      @model.stubs(:sentry)
      lambda { MockSentry.new(@model, @subject, @opts) }.should raise_error(Sentry::InvalidSetup)
    end
    
  end
  
end