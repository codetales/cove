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
          existing_containers = Steps::GetExistingContainerDetails.call(connection, service)

          roles.each do |role|
            running_containers = existing_containers.with_role(role).running.map(&:name)
            desired_containers = role.container_count.times.map { |index| DesiredContainer.from(role, index) }

            rolling_updates = [running_containers.length, desired_containers.length].max.times.map do |index|
              [
                running_container: running_containers[index],
                desired_container: desired_containers[index]
              ]
            end

            Steps::RollingUpdate.call(connection, rolling_updates)
          end

          Steps::Prune.call(connection, service, roles)
        end
      end
    end
  end
end
