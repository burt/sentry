describe Sentry::Base do
  
  before :each do
    @model = mock
    @subject = mock
    @opts = {}
  end
  
  after :each do
    @model.reset_mocha
    @subject.reset_mocha
  end
  
  
  
end