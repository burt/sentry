require 'active_support' # TODO: remove dependency

require 'sentry/errors'
require 'sentry/factory'
require 'sentry/rights'
require 'sentry/configuration'
require 'sentry/base'

module Sentry
  
  class << self
    attr_accessor :rights
    attr_accessor :configuration
  end

  def self.rights(&block)
    if block_given?
      @rights = Sentry::RightsBuilder.new.instance_eval(&block).rights
    else
      @rights
    end
  end

  def self.configure(&block)
    config = Configuration.new
    yield(config)
    self.configuration = config
  end
  
  # TODO: spec and document
  def self.method_missing(sym, *args, &block)
    self.configuration.send sym, *args, &block
  end
  
end

Sentry.configuration = Sentry::Configuration.new

Sentry.rights do
  create do
    actions :new, :create
  end
  read do
    actions :index, :show
  end
  update do
    actions :edit, :update
  end
  delete do
    actions :destroy
  end
end