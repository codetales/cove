module Cove
  module Invocation
    class ServiceUp
      include SSHKit::DSL

      # @param registry [Cove::Registry]
      # @param service [Cove::Service]
      def initialize(registry:, service:)
        # @type [Cove::Service]
        @service = service
        @registry = registry
      end

      # @return nil
      def invoke
        service = @service # Need to set a local var to be able to reference it in the block below
        registry = @registry
        roles = registry.roles_for_service(service)

        hosts = roles.flat_map(&:hosts).uniq.map(&:sshkit_host)
        on(hosts) do |host|
          coordinator = Coordinator.new(self, registry, service, roles)
          coordinator.run
        end

        nil
      end

      private

      class Coordinator
        # @return
        attr_reader :connection
        # @return [Cove::Registry]
        attr_reader :registry
        # @return [Cove::Service]
        attr_reader :service
        # @return [Array<Cove::Role>]
        attr_reader :roles

        def initialize(connection, registry, service, roles)
          @connection = connection
          @registry = registry
          @service = service
          @roles = roles
        end

        def run
          roles.each do |role|
            package = Package.build(registry, role)

            Steps::EnsureEnvironmentFileExists.call(connection, package)
            Steps::EnsureConfigsExist.call(connection, package.deployment_config)
            Steps::PullImage.call(connection, package.image)
            Steps::CreateMissingContainers.call(connection, package)
            Steps::RollContainers.call(connection, package)
          end
        end
      end
    end
  end
end
