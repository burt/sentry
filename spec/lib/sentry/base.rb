describe Sentry::Base do
  
  # test setting the accessors (remove any irrelevant respond tos)
  # test the authorize flag
  # test apply methods, thoroughly

=begin 
  before :each do
    @model = mock
    @subject = mock
    @options = {}
  end
=end
  
  describe "a new sentry base" do
    
    before :each do
      @sentry = Sentry::Base.new
    end
    
    it "should have the readers model, subject, rights, options and enabled" do
      @sentry.should respond_to(:model, :subject, :rights, :options, :enabled)
    end
    
    it "should not be an authorizer" do
      @sentry.authorizer?.should == false
    end
    
    it "should have an empty options hash" do
      @sentry.options.should be_an_instance_of(Hash)
      @sentry.options.should be_empty
    end
    
    it "should respond to filter, action_permitted? and right_permitted?" do
      @sentry.should respond_to(:filter, :action_permitted?, :right_permitted?)
    end   
    
  end
  
end