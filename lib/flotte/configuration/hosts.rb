require "yaml"
require "flotte/host"

module Flotte
  module Configuration
    class Hosts
      def initialize(config_file)
        @config_file = config_file
      end

      def all
        load_config

        @raw_host_config["hosts"].map do |entry|
          parse(entry)
        end
      end

      private

      def parse(entry)
        if Hash === entry
          Flotte::Host.new(defaults.merge(entry))
        else
          Flotte::Host.new(defaults.merge(name: entry))
        end
      end

      def defaults
        @raw_host_config["defaults"].slice("user")
      end

      def load_config
        @raw_host_config ||= YAML.load(ERB.new(contents).result)
      end

      def contents
        File.read(@config_file)
      end
    end
  end
end
