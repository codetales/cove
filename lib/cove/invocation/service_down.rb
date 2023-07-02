module Cove
  module Invocation
    class ServiceDown
      include SSHKit::DSL

      # @return [Cove::Registry]
      attr_reader :registry
      # @return [Cove::Service]
      attr_reader :service

      # @param registry [Cove::Registry]
      # @param service [Cove::Service]
      def initialize(registry:, service:)
        @service = service
        @registry = registry
      end

      # @return nil
      def invoke
        service = @service # Need to set a local var to be able to use it in the block below
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
          stop_containers
          delete_containers
        end

        def stop_containers
          connection.info "Stopping existing containers..."
          existing_containers.each do |container|
            @connection.execute(*Command::Builder.stop_container(container))
          end
        end

        def delete_containers
          connection.info "Deleting containers..."
          existing_containers.each do |container|
            @connection.execute(*Command::Builder.delete_container(container))
          end
        end

        def existing_containers
          @existing_containers ||= extract_running_containers.each_line.map(&:strip)
        end

        def extract_running_containers
          @connection.capture(*Command::Builder.list_containers_for_service(service), verbosity: Logger::INFO)
        end
      end
    end
  end
end
