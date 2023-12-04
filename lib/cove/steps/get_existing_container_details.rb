module Cove
  module Steps
    class GetExistingContainerDetails
      include Callable

      # @return [SSHKit::Backend::Abstract]
      attr_reader :connection

      # @return [Cove::Service, Cove::Role]
      attr_reader :entity

      # @param connection [SSHKit::Backend::Abstract]
      # @param entity [Cove::Service, Cove::Role, Cove::Deployment, Cove::Instance, Cove::Package]
      def initialize(connection, entity)
        @connection, @entity = connection, entity
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
        entity.labels.as_filters
      end
    end
  end
end
