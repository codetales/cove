# frozen_string_literal: true

require_relative "flotte/version"
require 'thor'
require 'sshkit'
require 'sshkit/dsl'

module Flotte
  class Error < StandardError; end

  module CLI
    class Main < Thor
      desc "version", "Print the installed version of flotte"
      def version
        puts Flotte::VERSION
      end
    end
  end
end
