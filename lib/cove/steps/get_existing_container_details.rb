module Cove
  module Steps
    class GetExistingContainerDetails
      include Callable

      # @return [SSHKit::Backend::Abstract]
      attr_reader :connection

      # @return [Cove::Service, Cove::Role]
      attr_reader :service_or_role

      def initialize(connection, service_or_role)
        @connection, @service_or_role = connection, service_or_role
      end

      # @return [Runtime::ContainerList]
      def call
        CaptureContainerDetails.call(connection, container_names)
      end

      private

      def container_names
        connection.capture(*DockerCLI::Container::List.matching(filters), verbosity: Logger::INFO)
          .each_line
          .map(&:strip)
          .reject(&:blank?)
      end

      def filters
        LabelsForEntity.new(service_or_role).to_a
      end
    end
  end
end
