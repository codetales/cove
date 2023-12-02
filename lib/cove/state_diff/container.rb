# Given a list of running and desired containers, this class will
# determine which containers need to be started, stopped, or restarted.
#
# It will perform a rolling restart where it first stops an existing container
# (if applicable) and then starts a new one before stopping the next one.
#
# If the number of desired containers is less than the number of running it first
# reduces the number of running containers to match the number of desired containers
# before continueing with a rolling restart.
#
# If the number of desired containers is greater than the number of running it first
# start a new container before continuing with a rolling restart.
#
# The containers version and index is used to determine whether it already exists. The running container
# instance also responds to `running?` to determine whether it is running or not.
#
# The set of instructions returned follows the following format:
# [
#  { :action => :stop, :container => <container> },
#  { :action => :start, :container => <container> },
#  { :action => :stop, :container => <container> },
#  { :action => :start, :container => <container> },
# ]

module Cove
  module StateDiff
    class Container
      Error = Class.new(StandardError)

      attr_reader :current_containers, :desired_containers

      def initialize(current_containers, desired_containers)
        @current_containers = current_containers
        @desired_containers = desired_containers
      end

      def instructions
        verify!

        # If we wanted to implement other strategies we could do that here.
        # E.g. start first, stop all
        return start_instructions if stoppable_containers.empty?
        stop_instructions.zip(start_instructions).flatten.compact
      end

      private

      def verify!
        found_containers = desired_containers.map do |desired_container|
          current_containers.find do |current_container|
            current_container.index == desired_container.index &&
              current_container.version == desired_container.version
          end
        end.compact

        raise Error.new("Missing Container") if found_containers.size < desired_containers.size
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

      def startable_containers
        current_containers.reject(&:running?).select do |current_container|
          desired_containers.any? do |desired_container|
            current_container.index == desired_container.index &&
              current_container.version == desired_container.version
          end
        end
      end

      def stoppable_containers
        current_containers.select(&:running?).select do |current_container|
          desired_containers.none? do |desired_container|
            current_container.index == desired_container.index &&
              current_container.version == desired_container.version
          end
        end
      end
    end
  end
end
