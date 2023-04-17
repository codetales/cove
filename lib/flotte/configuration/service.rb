require "yaml"
require "flotte/service"

module Flotte
  module Configuration
    class Service
      def initialize(config_file)
        @config_file = config_file
      end

      def build
        roles.each do |role|
          service.roles.add(role)
        end
        service
      end

      private

      def service
        @service ||= Flotte::Service.new(name: name, image:image, environment: service_environment)
      end

      def roles
        config["roles"].map do |name, role_config|
          role_environemnt = (service_environment.merge(role_config["environment"] || {}))
          Flotte::Service::Role.new(name: name, environment: role_environemnt)
        end
      end

      def name
        config["name"]
      end

      def image
        config["image"]
      end

      def service_environment
        config["environment"] || {}
      end

      def config
        @raw_service_config ||= YAML.safe_load(ERB.new(contents).result)
      end

      def contents
        File.read(@config_file)
      end
    end
  end
end
