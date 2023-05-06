# frozen_string_literal: true

require "active_support/all"
require "active_model"
require "thor"
require "sshkit"
require "sshkit/dsl"
require "yaml"
require_relative "cove/callable"
require_relative "cove/version"
require_relative "cove/dotenv"
require_relative "cove/registry"
require_relative "cove/host"
require_relative "cove/service"
require_relative "cove/role"
require_relative "cove/configuration"
require_relative "cove/command"
require_relative "cove/cli"
require_relative "cove/initialization"
require_relative "cove/invocation"
require_relative "cove/desired_container"
require_relative "cove/runtime"

module Cove
  class Error < StandardError; end

  def self.output=(output)
    @output = output
  end

  def self.output
    @output || $stdout
  end

  def self.init(config:)
    @registry = nil
    Initialization.new(config, registry).perform
  end

  def self.registry
    @registry ||= Registry.new
  end
end
