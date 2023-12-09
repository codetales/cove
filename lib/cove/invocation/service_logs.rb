module Cove
  module Invocation
    class ServiceLogs
      include SSHKit::DSL

      attr_reader :registry, :service

      # @param registry [Cove::Registry]
      # @param service [Cove::Service]
      def initialize(registry:, role:)
        # @type [Cove::Service]
        @role = role
        @registry = registry
      end

      # @return nil
      def invoke
        role = @role # Need to set a local var to be able to reference it in the block below

        on(role.hosts.map(&:sshkit_host)) do |host|
          coordinator = Coordinator.new(self, role)
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
          container = Steps::GetExistingContainerDetails.call(connection, service).find do |container|
            container.running?
          end

          return unless container

          SSHKit.config.output_verbosity = Logger::DEBUG
          connection.execute :docker, "logs", "--tail 50", "--follow", container.name
        end
      end
    end
  end
end
