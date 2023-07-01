module Cove
  module Steps
    class CreateMissingContainers
      include Callable

      # @return [SSHKit::Backend::Abstract]
      attr_reader :connection
      # @return [Cove::Service]
      attr_reader :role

      def initialize(connection, role)
        @connection, @role = connection, role
      end

      def call
        existing_containers = Steps::GetExistingContainerDetails.call(connection, role)
        desired_containers = 1.upto(role.container_count).map { |index| DesiredContainer.from(role, index) }
        state_diff = StateDiff.new(existing_containers, desired_containers)
        connection.info("Creating #{state_diff.containers_to_create.count} containers")

        state_diff.containers_to_create.each do |container|
          cmd = Command::Builder.create_container(container)
          connection.execute(*cmd)
        end
      end
    end
  end
end
