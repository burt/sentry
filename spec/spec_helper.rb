SPEC_ROOT = File.dirname(__FILE__)
$:.unshift(File.join(SPEC_ROOT))
$:.unshift(File.join(SPEC_ROOT, "..", "lib"))

require 'machinist/object'
require 'sham'
require 'faker'
require 'mocha'
require 'active_support'
require 'action_controller'
require 'pp'

require 'sentry'
require 'sentry/rails'
require 'support/matchers/matchers'

Spec::Runner.configure do |config|
  config.mock_with :mocha
  
  config.include(Support::Matchers)
  
  config.before do
    Sentry.configuration = Sentry::Configuration.new
    @rights = Sentry.rights = Sentry.rights do
      create { actions :new, :create }
      read { actions :show, :index; default true }
      update { actions :edit, :update }
      delete { actions :destroy }
    end
  end
end

Sham.title { Faker::Lorem.sentence }
Sham.name { Faker::Name.name }

module Mocks
  
  class ModelWithNoSentry; end

  class MockSentry < Sentry::Base

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

  class PostSentry < Sentry::Base
    
    def permitted?
      current_method != :create && subject.name == 'ringo'
    end

    def forbidden?
      subject.name == 'paul'
    end

    def can_create?
      puts "calling can_create? #{current_method} #{model.inspect} #{subject.inspect}"
      model.new_record == true
    end

    def can_read?
      model.published || subject == model.author
    end

    def can_update?
      subject == model.author
    end

    def can_delete?
      false
    end

  end

  class PostSentry2 < Sentry::Base; end

  class Post
    attr_accessor :title, :author, :published, :new_record
  end

  class User
    attr_accessor :name
  end

  class CurrentRightTestSentry < Sentry::Base
    Sentry.rights.each do |k, v|
      define_method v.method_name do
        self.current_right == v
      end
    end
  end
  
  class ApplicationController < ActionController::Base
    include Sentry::Rails::Authorisation
  end
  
end

Mocks::User.blueprint do
  name { Sham.name }
end

Mocks::Post.blueprint do
  title { Sham.title }
  published { false }
end


