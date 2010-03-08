describe Sentry::Configuration do
  
  describe "a new configuration" do
    
    before :each do
      @config = Sentry::Configuration.new
    end
    
    it "should have the user current_user" do
      @config.user_method.should == 'current_user'
    end
    
    it "should have an empty hash of rights" do
      @config.rights.should == {}
    end
    
  end
  
end

__END__

Sentry.configure do
  
  user_method :current_user
   
  rights do
    
    create do
      default false
      actions :new, :create
    end
    
    read
    
    update
    
    delete
    
    manage do
      includes :new, :create
    end
    
  end
  
end
