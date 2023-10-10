# frozen_string_literal: true

require "active_support/all"
require "active_model"
require "dry-validation"
require "thor"
require "sshkit"
require "sshkit/dsl"
require "airbrussh"
require "yaml"
require "zeitwerk"
require "dotenv"

Dotenv.load(".env.local", ".env")

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "cli" => "CLI",
  "docker_cli" => "DockerCLI"
)
loader.setup

module Cove
  class Error < StandardError; end

  def self.host_base_dir
    "/var/lib/cove"
  end

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
