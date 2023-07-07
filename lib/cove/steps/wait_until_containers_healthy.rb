module Cove
  module Steps
    class WaitUntilContainersHealthy
      class HealthCheckFailed < StandardError
        attr_reader :containers

        def initialize(containers)
          @containers = containers

          super("Health check failed for containers: #{containers.map(&:name).join(", ")}")
        end
      end

      include Callable

      # @return [SSHKit::Backend::Abstract]
      attr_reader :connection
      # @return [Array<String>]
      attr_reader :container_names

      # @param connection [SSHKit::Backend::Abstract]
      # @param container_names [Array<String>] The names of the containers to wait to become healthy
      # @param max_attempts [Integer] The maximum number of attempts to wait for the containers to become healthy
      # @param wait_time [Integer] The number of seconds to wait between attempts
      # @param sleeper [#sleep] An object that responds to #sleep and sleeps for the given number of seconds
      def initialize(connection, container_names, max_attempts: 10, wait_time: 30, sleeper: Sleeper)
        @connection, @container_names = connection, container_names
        @max_attempts = max_attempts
        @wait_time = wait_time
        @sleeper = sleeper
      end

      def call
        attempts ||= 1

        containers = CaptureContainerDetails.call(connection, container_names)
        unhealthy_containers = containers.reject(&:healthy?)

        raise HealthCheckFailed.new(unhealthy_containers) if unhealthy_containers.any?
        true
      rescue HealthCheckFailed => e
        attempts += 1

        if attempts > @max_attempts
          raise e
        else
          @sleeper.sleep @wait_time
          retry
        end
      end
    end
  end
end
