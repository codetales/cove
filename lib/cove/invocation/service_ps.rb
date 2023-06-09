module Cove
  module Invocation
    class ServicePs
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
          coordinator = Coordinator.new(self, service)
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

        def initialize(connection, service)
          @connection = connection
          @service = service
        end

        def run
          containers = Steps::GetExistingContainerDetails.call(connection, service)
          containers.each do |container|
            Cove.output.puts "#{container.name} #{container.status} #{container.healthy?}"
          end
        end
      end
    end
  end
end
