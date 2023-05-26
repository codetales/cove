module Cove
  module Invocation
    module Steps
      class GetExistingContainerDetails
        include Callable

        # @return [SSHKit::Backend::Abstract]
        attr_reader :connection
        # @return [Cove::Service]
        attr_reader :service

        def initialize(connection, service)
          @connection, @service = connection, service
        end

        def call
          container_names = connection.capture(*Command::Builder.list_containers_matching(filters), verbosity: Logger::INFO)
            .each_line
            .map(&:strip)
            .reject(&:blank?)
          return Runtime::ContainerList.new if container_names.empty?

          json = connection.capture(*Command::Builder.inspect_containers(container_names), verbosity: Logger::INFO)
          containers = JSON.parse(json).map do |config|
            Runtime::Container.build_from_config(config)
          end
          Runtime::ContainerList.new(containers)
        end

        private

        # @param [Cove::Entity] entity
        # @return [Array]
        def filters
          service.labels.map do |key, value|
            "label=#{key}=#{value}"
          end
        end
      end
    end
  end
end
