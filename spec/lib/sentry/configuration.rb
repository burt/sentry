describe Sentry::Configuration do
  
  describe "a new configuration" do
    
    before :each do
      @config = Sentry::Configuration.new
    end
    
    it "should respond to name" do
      @config.should respond_to(:name)
    end
    
  end
  
end