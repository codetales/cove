module Cove
  module Steps
    class GetExistingContainerDetails
      include Callable

      # @return [SSHKit::Backend::Abstract]
      attr_reader :connection
      attr_reader :service_or_role

      def initialize(connection, service_or_role)
        @connection, @service_or_role = connection, service_or_role
      end

      def call
        container_names = connection.capture(*DockerCLI::Container::List.names_matching(filters), verbosity: Logger::INFO)
          .each_line
          .map(&:strip)
          .reject(&:blank?)
        return Runtime::ContainerList.new if container_names.empty?

        json = connection.capture(*DockerCLI::Container::Inspect.build(container_names), verbosity: Logger::INFO)
        containers = JSON.parse(json).map do |config|
          Runtime::Container.build_from_config(config)
        end
        Runtime::ContainerList.new(containers)
      end

      private

      # @param [Cove::Entity] entity
      # @return [Array]
      def filters
        service_or_role.labels.map do |key, value|
          "label=#{key}=#{value}"
        end
      end
    end
  end
end
