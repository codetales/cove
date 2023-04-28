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
        service = @service # Need to set a local var to be able to use it in the block below
        roles = registry.roles.select { |role| role.service == service }

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
          start_containers
        end

        def stop_containers
          connection.info "Checking for running containers..."
          connection.info "Stopping existing containers..." if existing_containers.any?
          existing_containers.each do |container|
            @connection.execute(*Command::Builder.stop_container(container))
          end
        end

        def existing_containers
          @existing_containers ||= extract_running_containers.each_line.map(&:strip)
        end

        def extract_running_containers
          @connection.capture(*Command::Builder.list_containers_for_service(service), verbosity: Logger::INFO)
        end

        def start_containers
          roles.each do |role|
            @connection.execute(*Command::Builder.start_container_for_role(role))
          end
        end
      end
    end
  end
end
