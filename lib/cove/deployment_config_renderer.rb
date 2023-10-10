module Cove
  class DeploymentConfigRenderer
    attr_reader :registry, :deployment

    # @param registry [Cove::Registry]
    # @param deployment [Cove::Deployment]
    def initialize(registry, deployment)
      @registry = registry
      @deployment = deployment
    end

    # @param template [String] Path to the template file
    # @return [String] Rendered template
    def call(template)
      # TODO: Calculate the correct path to the template file
      ERB.new(template, trim_mode: "-").result(binding)
    end

    # TODO: Move this to a helper and expose the helper to the ERB context

    def host_running(query)
      HostsQuery.new(@registry).resolve(query).first
    end

    def hosts_running(query)
      HostsQuery.new(@registry).resolve(query)
    end

    delegate :service_name, :role_name, :version, to: :deployment

    class HostsQuery
      attr_reader :registry

      def initialize(registry)
        @registry = registry
      end

      def resolve(query)
        query.match?("/") ? hosts_for_role(query) : hosts_for_service(query)
      end

      private

      def hosts_for_service(service_name)
        service = registry.services[service_name]
        registry.hosts_for_service(service)
      end

      def hosts_for_role(role_name)
        role = registry.roles[role_name]
        registry.hosts_for_roles(role)
      end
    end
  end
end
