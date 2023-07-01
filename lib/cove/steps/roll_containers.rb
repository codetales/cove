module Cove
  module Steps
    class RollContainers
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

        connection.info("Stopping additional #{state_diff.containers_to_stop.count} containers")
        state_diff.containers_to_stop.each do |container|
          cmd = Command::Builder.stop_container(container.name)
          connection.execute(*cmd)
        end

        connection.info("Starting additional #{state_diff.containers_to_start.count} containers")
        state_diff.containers_to_start.each do |container|
          cmd = Command::Builder.start_container(container.name)
          connection.execute(*cmd)
        end

        connection.info("Replacing #{state_diff.containers_to_replace.count} containers")
        state_diff.containers_to_replace.each do |replacement|
          cmd = Command::Builder.stop_container(replacement[:old].name)
          connection.execute(*cmd)

          cmd = Command::Builder.start_container(replacement[:new].name)
          connection.execute(*cmd)
        end
      end
    end
  end
end
