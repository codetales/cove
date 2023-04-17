require "yaml"
require "flotte/service"

module Flotte
  module Configuration
    class Service
      def initialize(config_file)
        @config_file = config_file
      end

      def service
        Flotte::Service.new(config)
      end

      private

      def config
        @raw_host_config ||= YAML.safe_load(ERB.new(contents).result)
      end

      def contents
        File.read(@config_file)
      end
    end
  end
end
