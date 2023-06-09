module Cove
  module Invocation
    class ServiceUp
      include SSHKit::DSL

      attr_reader :registry, :service

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
        roles = registry.roles_for_service(service)

        hosts = roles.flat_map(&:hosts).uniq.map(&:sshkit_host)
        on(hosts) do |host|
          coordinator = Coordinator.new(self, service, roles)
          coordinator.run
        end

        nil
      end

      private

      class Coordinator
        # @return
        attr_reader :connection
        # @return [Cove::Service]
        attr_reader :service
        # @return [Array<Cove::Role>]
        attr_reader :roles

        def initialize(connection, service, roles)
          @connection = connection
          @service = service
          @roles = roles
        end

        def run
          roles.each do |role|
            deployment = Deployment.new(role)

            Steps::EnsureEnvironmentFileExists.call(connection, deployment)
            Steps::PullImage.call(connection, deployment)
            Steps::CreateMissingContainers.call(connection, deployment)
            Steps::RollContainers.call(connection, deployment)
          end
        end
      end
    end
  end
end
