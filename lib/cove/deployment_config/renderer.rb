module Cove
  class DeploymentConfig
    class Renderer
      attr_reader :registry, :deployment

      def initialize(registry, deployment)
        @registry = registry
        @deployment = deployment
      end

      def call(template)
        ERB.new(template, trim_mode: "-").result(binding)
      end

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
end
