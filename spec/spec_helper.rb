SPEC_ROOT = File.dirname(__FILE__)
$:.unshift(File.join(SPEC_ROOT, "..", "lib"))

require 'machinist/object'
require 'mocha'

require 'sentry'