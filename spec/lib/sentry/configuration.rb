describe Sentry::Configuration do

  # check the defaults
  # check the singleton

  describe "a new configuration" do
    
    before :each do
      @config = Sentry::Configuration.new
    end
    
    it "should respond to user_method, not_permitted_redirect, not_permitted_message and enabled" do
      @config.should respond_to(:user_method, :not_permitted_redirect, :not_permitted_message, :enabled)
    end
    
    it "should return current_user for user_method" do
      @config.user_method.should == :current_user
    end
    
    it "should return true for enabled" do
      @config.enabled.should be_true
    end
    
    it "should return root_path for not_permitted_redirect" do
      @config.not_permitted_redirect.should == :root_path
    end
    
    it "should return 'You are not permitted to visit this section.' for not_permitted_message" do
      @config.not_permitted_message == 'You are not permitted to visit this section.'
    end
    
  end
  
end