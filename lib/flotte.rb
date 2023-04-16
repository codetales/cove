# frozen_string_literal: true

require "active_support/all"
require "thor"
require "sshkit"
require "sshkit/dsl"
require_relative "flotte/version"
require_relative "flotte/host"
require_relative "flotte/configuration"
require_relative "flotte/command"
require_relative "flotte/cli"

module Flotte
  class Error < StandardError; end
end
