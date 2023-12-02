# Given a list of running and desired containers, this class will
# determine which containers need to be started, stopped, or restarted.
#
# It will perform a rolling restart where it first stops an existing container
# (if applicable) and then starts a new one before stopping the next one.
#
# If the number of desired containers is less than the number of running
# containers it first reduces the number of running containers to match the
# number of desired containers before continuing with a rolling restart for the
# remaining containers.
#
# If the number of desired containers is greater than the number of running
# containers it first start new containers to match the number of desired
# containers before continuing with a rolling restart.
#
# The containers version and index is used to determine whether it already exists.
#
# The set of instructions returned follows the following format:
# [
#  { action: :stop, container: => <container name> },
#  { action: :start, container: => <container name> },
#  { action: :stop, container: => <container name> },
#  { action: :start, container: => <container name> },
# ]
module Cove
  module StateDiff
    class ContainerStatus
      Error = Class.new(StandardError)

      attr_reader :current_containers, :desired_containers

      def initialize(current_containers, desired_containers)
        @current_containers = current_containers
        @desired_containers = desired_containers
      end

      # TODO: Return objects instead of a hashes
      def instructions
        verify!

        # If we wanted to implement other strategies we could do that here.
        # E.g. start first, stop all
        if running_containers.size >= desired_containers.size
          padded_start_instructions = padding(stop_instructions.size - start_instructions.size) + start_instructions
          stop_instructions.zip(padded_start_instructions).flatten.compact
        else
          padded_stop_instructions = stop_instructions + padding(start_instructions.size - stop_instructions.size)
          start_instructions.zip(padded_stop_instructions).flatten.compact
        end
      end

      private

      def padding(size)
        [nil] * size
      end

      def verify!
        missing_containers = desired_containers.reject do |desired_container|
          current_containers.any? do |current_container|
            matching?(current_container, desired_container)
          end
        end

        raise Error.new("Can't construct steps to reconcile container statuses, the following containers are missing: #{missing_containers.map(&:name)}") if missing_containers.any?
      end

      def stop_instructions
        stoppable_containers.map do |container|
          {action: :stop, container: container.name}
        end
      end

      def start_instructions
        startable_containers.map do |container|
          {action: :start, container: container.name}
        end
      end

      def running_containers
        current_containers.select(&:running?)
      end

      def startable_containers
        current_containers.reject(&:running?).select do |current_container|
          desired_containers.any? do |desired_container|
            matching?(current_container, desired_container)
          end
        end
      end

      def stoppable_containers
        current_containers.select(&:running?).select do |current_container|
          desired_containers.none? do |desired_container|
            matching?(current_container, desired_container)
          end
        end
      end

      def matching?(container1, container2)
        container1.index == container2.index &&
          container1.version == container2.version
      end
    end
  end
end
