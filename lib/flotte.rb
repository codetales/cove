# frozen_string_literal: true

require "active_support/all"
require "dotenv/load"
require "thor"
require "sshkit"
require "sshkit/dsl"
require_relative "flotte/version"
require_relative "flotte/registry"
require_relative "flotte/host"
require_relative "flotte/configuration"
require_relative "flotte/command"
require_relative "flotte/cli"

module Flotte
  class Error < StandardError; end

  def self.output=(output)
    @output = output
  end

  def self.output
    @output || $stdout
  end

  def self.init(config: "./")
    host_config = Flotte::Configuration::Hosts.new(File.join(config, "hosts.yml"))
    host_config.all.each do |host|
      registry.hosts.add(host)
    end
  end

  def self.registry
    @registry ||= Flotte::Registry.new
  end
end
