describe Sentry::RailsController do
  
  describe "a Mocks::ApplicationController" do
    
    before :each do
      @controller = Mocks::ApplicationController.new
    end
    
    it "should call the method defined by Sentry.configuration.user_method on sentry_user" do
      Sentry.configuration.user_method = :current_user
      user = Object.new
      @controller.stubs(:current_user).returns(user)
      @controller.sentry_user.should === user
    end
    
    describe "when not_authorized is called" do
      
      before :each do
        @flash = {}
        @controller.stubs(:flash).returns(@flash)
        @controller.stubs(:redirect_to)
      end
      
      it "should set flash[:error] to Sentry.configuration.not_permitted_message" do
        @controller.not_authorized
        @flash[:error].should == Sentry.configuration.not_permitted_message
      end
      
      it "should redirect to Sentry.configuration.not_permitted_redirect" do
        @controller.stubs(:redirect_to).with(Sentry.configuration.not_permitted_redirect.to_s)
        @controller.not_authorized
      end
      
    end
    
    it "should have can_ methods for each right" do
      @rights.each do |k, v|
        @controller.should respond_to v.method_name
      end
    end
    
    describe "given the current user is George and there is a Post created by John" do
      
      before :each do
        @john = Mocks::User.make(:name => 'john')
        @george = Mocks::User.make(:name => 'george')
        @post = Mocks::Post.make(:author => @john, :published => true, :new_record => false)
        @controller.stubs(:current_user).returns(@george)
      end
      
      it "should return false to can_create?" do
        @controller.can_create?(@post).should be_false
      end
      
      it "should return true to can_read?" do
        @controller.can_read?(@post).should be_true
      end
      
      it "should return false to can_update?" do
        @controller.can_update?(@post).should be_false
      end
      
      it "should return fales to can_delete?" do
        @controller.can_delete?(@post).should be_false
      end
      
    end
    
  end
  
end