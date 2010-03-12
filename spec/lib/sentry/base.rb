describe Sentry::Base do
  
  before :each do
    @model = mock
    @subject = mock
    @opts = {}
  end
  
  describe "a new sentry base" do
    
    before :each do
      @sentry = Sentry::Base.new
    end
    
    it "should have the readers :model, :subject, :rights, :opts, :enabled" do
      @sentry.should respond_to(:model, :subject, :rights, :opts, :enabled)
    end
    
  end
  
  
  
  #@a = Sentry::Base.new(nil, nil, nil)
  #@a.should respond_to :can_create?
  #@a.should respond_to :old_can_create?
  #@a.can_create?
  
  #@b = Sentry::Base.new(nil, nil, nil)
  #@b.should_not respond_to(:can_create?)
  #@b.should_not respond_to(:old_can_create?)
  
end