# frozen_string_literal: true

require 'active_support/all'
require 'thor'
require 'sshkit'
require 'sshkit/dsl'
require_relative "flotte/version"
require_relative "flotte/command"

module Flotte
  class Error < StandardError; end

  module CLI
    class Main < Thor
      include SSHKit::DSL

      desc "version", "Print the installed version of flotte"
      def version
        puts Flotte::VERSION
      end

      desc "runit", "Run a command"
      def runit
        say "test", "blue"
        captured = {}
        image = "hello-world"
        container_name = "test-#{SecureRandom.alphanumeric(5)}"
        on(["root@test"]) do |host|
          output = capture(*Command::Docker::Container::Run.build(image: image, name: container_name), {verbosity: Logger::INFO})

          captured[host] = output
        end

        p captured
      end
    end
  end
end
