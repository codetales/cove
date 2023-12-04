module Cove
  module Steps
    class CreateMissingContainers
      include Callable

      # @return [SSHKit::Backend::Abstract]
      attr_reader :connection
      # @return [Cove::Service]
      attr_reader :package

      def initialize(connection, package)
        @connection, @package = connection, package
      end

      def call
        connection.info("Creating #{state_diff.containers_to_create.count} containers")

        state_diff.containers_to_create.each do |container|
          cmd = Command::Builder.create_container(container)
          connection.execute(*cmd)
        end
      end

      def state_diff
        @state_diff ||= StateDiff::ContainerExistance.new(existing_containers, desired_containers)
      end

      def existing_containers
        Steps::GetExistingContainerDetails.call(connection, package)
      end

      def desired_containers
        1.upto(package.container_count).map do |index|
          instance = Instance.new(package, index)
          DesiredContainer.from(instance)
        end
      end
    end
  end
end
