module Flotte
  module Invocation
    class ServiceUp
      include SSHKit::DSL

      attr_reader :registry, :service

      # @param registry [Flotte::Registry]
      # @param service [Flotte::Service]
      def initialize(registry:, service:)
        # @type [Flotte::Service]
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
        attr_reader :backend
        # @return [Flotte::Service]
        attr_reader :service
        # @return [Array<Flotte::Role>]
        attr_reader :roles

        def initialize(backend, service, roles)
          @backend = backend
          @service = service
          @roles = roles
        end

        def run
          stop_containers
          start_containers
        end

        def stop_containers
          backend.info "Checking for running containers..."
          backend.info "Stopping existing containers..." if existing_containers.any?
          existing_containers.each do |container|
            @backend.execute(*Command::Builder.stop_container(container))
          end
        end

        def existing_containers
          @existing_containers ||= extract_running_containers.each_line.map(&:strip)
        end

        def extract_running_containers
          @backend.capture(*Command::Builder.list_containers_for_service(service), verbosity: Logger::INFO)
        end

        def start_containers
          roles.each do |role|
            @backend.execute(*Command::Builder.start_container_for_role(role))
          end
        end
      end
    end
  end
end
