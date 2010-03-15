SPEC_ROOT = File.dirname(__FILE__)
$:.unshift(File.join(SPEC_ROOT))
$:.unshift(File.join(SPEC_ROOT, "..", "lib"))

require 'machinist/object'
require 'mocha'
require 'active_support'
require 'pp'
require 'support/matchers/matchers'

Spec::Runner.configure do |config|
  config.mock_with :mocha
  config.include(Support::Matchers)  
end

require 'sentry'

module Mocks
  
  class Post; end

  class User; end
  
  class PostSentry < Sentry::Base

    def can_create?
      true
    end

    def can_update?
      true
    end

    def can_delete?
      false
    end

  end
  
  class BadSentry; end
  
end
