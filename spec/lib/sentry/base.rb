describe Sentry::Base do
  
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
  
  describe "the sentry base class" do
    
    it "should respond to base_methods with all Sentry::Base public instance methods" do
      base_methods = Sentry::Base.base_methods
      base_methods.should be_an_instance_of Array
      base_methods.should == Sentry::Base.public_instance_methods
    end
    
    it "should respond to sentry_methods with an empty array" do
      sentry_methods = Sentry::Base.sentry_methods
      sentry_methods.should be_an_instance_of Array
      sentry_methods.should == []
    end
    
  end
  
  describe "subclasses of sentry base" do
    
  end
  
  describe "a valid sentry" do
    
    before :each do
      @model = mock
      @subject = mock
      @opts = {}
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
    
  end
  
  

=begin
  describe "a new base sentry" do
    
    before :each do
      @sentry = Sentry::Base
      @subject.stubs(:name).returns('brent')
    end
    
    it "should work" do
      @subject.name.should == 'brent'
    end
    
  end
=end
  
end