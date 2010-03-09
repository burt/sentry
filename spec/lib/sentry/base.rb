describe Sentry::Base do
  
  before :each do
    @model = mock
    @subject = mock
    @opts = {}
  end
  
  it "should work" do
    #@a = Sentry::Base.new(nil, nil, nil)
    #@a.should respond_to :can_create?
    #@a.should respond_to :old_can_create?
    #@a.can_create?
    
    #@b = Sentry::Base.new(nil, nil, nil)
    #@b.should_not respond_to(:can_create?)
    #@b.should_not respond_to(:old_can_create?)
  end
  
end