require "byebug"
module Cove
  module Steps
    class RollContainers
      include Callable

      # @return [SSHKit::Backend::Abstract]
      attr_reader :connection
      # @return [Cove::Service]
      attr_reader :role
      # @return [Cove::Deployment]
      attr_reader :deployment

      def initialize(connection, deployment)
        @connection, @deployment = connection, deployment
        @role = deployment.role
      end

      def call
        stop_additional_containers
        start_additional_containers
        replace_containers
      end

      private

      def stop_additional_containers
        connection.info("Stopping additional #{state_diff.containers_to_stop.count} containers")
        state_diff.containers_to_stop.each do |container|
          cmd = Command::Builder.stop_container(container.name)
          connection.execute(*cmd)
        end
      end

      def start_additional_containers
        connection.info("Starting additional #{state_diff.containers_to_start.count} containers")
        state_diff.containers_to_start.each do |container|
          cmd = Command::Builder.start_container(container.name)
          connection.execute(*cmd)
        end
      end

      def replace_containers
        connection.info("Replacing #{state_diff.containers_to_replace.count} containers")
        state_diff.containers_to_replace.each do |replacement|
          cmd = Command::Builder.stop_container(replacement[:old].name)
          connection.execute(*cmd)

          cmd = Command::Builder.start_container(replacement[:new].name)
          connection.execute(*cmd)
        end
      end

      def state_diff
        @state_diff ||= StateDiff::ContainerStatus.new(existing_containers, desired_containers)
      end

      def existing_containers
        Steps::GetExistingContainerDetails.call(connection, role)
      end

      def desired_containers
        1.upto(role.container_count).map do |index|
          instance = Instance.new(deployment, index)
          DesiredContainer.from(instance)
        end
      end
    end
  end
end
