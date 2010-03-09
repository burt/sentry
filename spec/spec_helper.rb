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
  
  class MockModelSentry < Sentry::Base; end
  
  class MockModelSentry2 < MockModelSentry; end
  
  class BadSentry; end
  
end