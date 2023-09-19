module Cove
  module Configuration
    class Service
      def initialize(config_file, host_registry)
        @config_file = config_file
        @host_registry = host_registry
        validate!
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
            command: role_config["command"],
            ports: role_config["ingress"],
            mounts: role_config["mounts"],
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

      private

      def validate!
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: service_name, image: image, roles: formatted_roles)
        if result.failure?
          Cove.output.puts result.errors.to_h
          Kernel.exit(1)
        end
      end

      def formatted_roles
        config["roles"].map do |role_name, role_config|
          {name: role_name, container_count: role_config["container_count"], ingress: role_config["ingress"], mounts: role_config["mounts"]}.compact
        end
      end
    end
  end
end
