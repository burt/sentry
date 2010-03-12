# TODO: test the option merging

describe Sentry::Factory do

=begin
  describe "at construction" do
  
    it "should raise an argument error given no source" do
      lambda { Sentry::Factory.new(nil, {}, {}) }.should raise_error(ArgumentError)
    end
  
    it "should raise an argument error given no subject" do
      lambda { Sentry::Factory.new({}, nil, {}) }.should raise_error(ArgumentError)
    end
  
    it "should raise an argument error if options isn't a hash" do
      lambda { Sentry::Factory.new({}, {}, 1) }.should raise_error(ArgumentError)
    end
  
    it "should not raise an argument error given valid arguments" do
      lambda { Sentry::Factory.new({}, {}) }.should_not raise_error
      lambda { Sentry::Factory.new({}, {}, {}) }.should_not raise_error
    end
    
  end
  
  describe "a new factory" do
  
    before :each do
      @subject = mock
      @model = Specs::MockModel.new
    end
    
    describe "with a model of type Specs::MockModel" do
    
      describe "and no options" do
      
        before :each do
          @factory = Sentry::Factory.new(@model, @subject)
        end
      
        it "should have a sentry class name of Specs::MockModelSentry" do
          @factory.sentry_class_name.should == 'Specs::MockModelSentry'
        end
      
        it "should return an instance of Specs::MockModelSentry on create" do
          @factory.create.should be_an_instance_of Specs::MockModelSentry
          @factory.create.model.should == @model
          @factory.create.subject.should == @subject
        end
      
      end
    
      describe "and the class option set to Specs::MockModelSentry2" do
      
        before :each do
          @options = {:class => 'Specs::MockModelSentry2'}
          @factory = Sentry::Factory.new(@model, @subject, @options)
        end
      
        it "should have a sentry class name of Specs::MockModelSentry2" do
          @factory.sentry_class_name.should == 'Specs::MockModelSentry2'
        end
        
        it "should return an instance of Specs::MockModel2 on create" do
          @factory.create.should be_an_instance_of Specs::MockModelSentry2
          @factory.create.model.should == @model
          @factory.create.subject.should == @subject
        end
      
      end
      
    end
    
    it "should raise SentryNotDefined when the corresponding sentry class does not exist" do
      @factory = Sentry::Factory.new(mock, @subject)
      lambda { @factory.create }.should raise_error(Sentry::SentryNotDefined)
    end
    
    it "should raise SentryNotDefined when the corresponding sentry class does not inherit from Sentry::Base" do
      @factory = Sentry::Factory.new(@model, @subject, :class => 'Specs::BadSentry')
      lambda { @factory.create }.should raise_error(Sentry::InvalidSentry)
    end
  
  end
=end 
end