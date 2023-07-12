module Cove
  module Configuration
    class Service
      def initialize(config_file, host_registry)
        @config_file = config_file
        @host_registry = host_registry
      end

      def build
        self
      end

      def service
        @service ||= Cove::Service.new(name: service_name, image: image, default_environment: service_environment)
      end

      def roles
        @roles ||= config["roles"].map do |role_name, role_config|
          role_environment = service_environment.merge(role_config["environment"] || {})
          Cove::Role.new(
            name: role_name,
            service: service,
            container_count: role_config["container_count"],
            environment_variables: role_environment,
            hosts: role_config["hosts"].map { |host_id| @host_registry[host_id] }
          )
        end
      end

      def service_name
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
