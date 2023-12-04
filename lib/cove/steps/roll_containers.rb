module Cove
  module Steps
    class RollContainers
      include Callable

      # @return [SSHKit::Backend::Abstract]
      attr_reader :connection
      # @return [Cove::Service]
      attr_reader :role
      # @return [Cove::package]
      attr_reader :package

      def initialize(connection, package)
        @connection, @package = connection, package
        @role = package.role
      end

      def call
        state_diff.instructions.each do |instruction|
          case instruction[:action]
          when :start
            start_container(instruction[:container])
          when :stop
            stop_container(instruction[:container])
          end
        end
      end

      private

      def start_container(container_name)
        cmd = Command::Builder.start_container(container_name)
        connection.execute(*cmd)
      end

      def stop_container(container_name)
        cmd = Command::Builder.stop_container(container_name)
        connection.execute(*cmd)
      end

      def state_diff
        @state_diff ||= StateDiff::ContainerStatus.new(existing_containers, desired_containers)
      end

      def existing_containers
        Steps::GetExistingContainerDetails.call(connection, role)
      end

      def desired_containers
        1.upto(role.container_count).map do |index|
          instance = Instance.new(package, index)
          DesiredContainer.from(instance)
        end
      end
    end
  end
end
