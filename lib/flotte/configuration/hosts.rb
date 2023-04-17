require "yaml"
require "flotte/host"

module Flotte
  module Configuration
    class Hosts
      ALLOWED_DEFAULT_KEYS = ["user"]

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
        @raw_host_config["defaults"].slice(*ALLOWED_DEFAULT_KEYS)
      end

      def load_config
        @raw_host_config ||= YAML.safe_load(ERB.new(contents).result)
      end

      def contents
        File.read(@config_file)
      end
    end
  end
end
