module Cove
  module Steps
    class CheckContainerHealth
      class HealthCheckFailed < StandardError
        def initialize(containers)
          @containers = containers

          super("Health check failed for containers: #{containers.map(&:name).join(', ')}")
        end
      end

      include Callable

      # @return [SSHKit::Backend::Abstract]
      attr_reader :connection
      attr_reader :container_names

      def initialize(connection, container_names)
        @connection, @container_names = connection, container_names
      end

      def call
        containers = CaptureContainerDetails.call(connection, container_names)
        if containers.all?(&:healthy?)
          return true
        else
          raise HealthCheckFailed.new(containers.reject(&:healthy?)))
        end
      rescue HealthCheckFailed => e

      end

      private

      # @param [Cove::Role, Cove::Service] entity
      # @return [Array<String>]
      def filters
        LabelsForEntity.new(service_or_role).to_a
      end
    end
  end
end
