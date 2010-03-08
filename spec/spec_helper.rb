SPEC_ROOT = File.dirname(__FILE__)
$:.unshift(File.join(SPEC_ROOT, "..", "lib"))

require 'machinist/object'
require 'mocha'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

require 'sentry'

module Specs
  
  class MockModel; end
  
  class MockModelSentry < Sentry::Base
    %w{ creatable? readable? updatable? deletable? }.each do |m|
      define_method m do
        true
      end
    end
  
    protected
    def a_protected_method
      true
    end
  
    private
    def a_private_method
      true
    end
  end
  
  class MockModelSentry2 < MockModelSentry; end
end