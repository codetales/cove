# frozen_string_literal: true

require "active_support/all"
require "active_model"
require "thor"
require "sshkit"
require "sshkit/dsl"
require "yaml"

require_relative "cove/dotenv"

require_relative "cove/callable"
require_relative "cove/version"
require_relative "cove/registry"
require_relative "cove/host"
require_relative "cove/service"
require_relative "cove/role"
require_relative "cove/deployment"
require_relative "cove/instance"
require_relative "cove/entity_labels"
require_relative "cove/environment_file"
require_relative "cove/configuration"
require_relative "cove/command"
require_relative "cove/cli"
require_relative "cove/initialization"
require_relative "cove/docker_cli"
require_relative "cove/steps"
require_relative "cove/invocation"
require_relative "cove/desired_container"
require_relative "cove/state_diff"
require_relative "cove/runtime"

module Cove
  class Error < StandardError; end

  def self.output=(output)
    @output = output
  end

  def self.output
    @output || $stdout
  end

  def self.init(config: ENV.fetch("COVE_CONFIG_DIR", "./"))
    @registry = nil
    Initialization.new(config, registry).perform
  end

  def self.registry
    @registry ||= Registry.new
  end
end
