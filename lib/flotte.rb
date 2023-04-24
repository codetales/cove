# frozen_string_literal: true

require "active_support/all"
require "dotenv/load"
require "thor"
require "sshkit"
require "sshkit/dsl"
require "yaml"
require_relative "flotte/version"
require_relative "flotte/registry"
require_relative "flotte/host"
require_relative "flotte/service"
require_relative "flotte/role"
require_relative "flotte/configuration"
require_relative "flotte/command"
require_relative "flotte/cli"
require_relative "flotte/initialization"

module Flotte
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
