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
            existing_containers = existing_containers.with_role(role)
            desired_containers = 1.upto(role.container_count).map { |index| DesiredContainer.from(role, index) }

            state_diff = StateDiff.new(existing_containers, desired_containers)
            Steps::PullImage.call(connection, role)

            state_diff.containers_to_create.each do |container|
              cmd = Command::Builder.create_container(container)
              connection.execute(*cmd)
            end

            state_diff.containers_to_stop.each do |container|
              cmd = Command::Builder.stop_container(container.name)
              connection.execute(*cmd)
            end

            state_diff.containers_to_start.each do |container|
              cmd = Command::Builder.start_container(container.name)
              connection.execute(*cmd)
            end

            state_diff.containers_to_replace.each do |replacement|
              cmd = Command::Builder.stop_container(replacement[:old].name)
              connection.execute(*cmd)

              cmd = Command::Builder.start_container(replacement[:new].name)
              connection.execute(*cmd)
            end
          end

          # Steps::Prune.call(connection, service, roles)
        end
      end
    end
  end
end
