describe Sentry::Configuration do

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
  
  describe "the Sentry module" do
    
    it "should respond to configuration" do
      Sentry.should respond_to :configuration
    end
    
    it "should have a default configuration set" do
      Sentry.configuration.should be_an_instance_of(Sentry::Configuration)
    end
    
    describe "when configure is called with a block" do
      
      before :each do
        @original_config = Sentry.configuration
        @enabled = enabled = false
        @user_method = user_method = :other_current_user
        @not_permitted_redirect = not_permitted_redirect = :not_root_path
        @not_permitted_message = not_permitted_message = "You're name's not down you're not coming in."    
        @returned = Sentry.configure do |c|
          c.enabled = enabled
          c.user_method = user_method
          c.not_permitted_redirect = not_permitted_redirect
          c.not_permitted_message = not_permitted_message
        end
      end
      
      it "should return the new configuration" do
        @returned.should be_an_instance_of(Sentry::Configuration)
      end
            
      it "should overwrite the configuration singleton" do
        Sentry.configuration.should_not === @original_config
        Sentry.configuration.should === @returned
      end
      
      it "should configure the new object" do
        @returned.enabled.should == @enabled
        @returned.user_method.should == @user_method
        @returned.not_permitted_redirect.should == @not_permitted_redirect
        @returned.not_permitted_message.should == @not_permitted_message
      end
      
    end
    
  end
  
end
