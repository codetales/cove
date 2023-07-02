module Cove
  module Steps
    class CaptureContainerDetails
      include Callable

      # @return [SSHKit::Backend::Abstract]
      attr_reader :connection
      # @return [Array<String>]
      attr_reader :container_names

      # @param connection [SSHKit::Backend::Abstract]
      # @param container_names [Array<String>]
      def initialize(connection, container_names)
        @connection, @container_names = connection, container_names
      end

      def call
        return Runtime::ContainerList.new if container_names.empty?

        JSON.parse(capture_container_details).map do |config|
          Runtime::Container.build_from_config(config)
        end.then do |containers|
          Runtime::ContainerList.new(containers)
        end
      end

      private

      def capture_container_details
        connection.capture(*inspect_command(container_names), verbosity: Logger::INFO)
      end

      def inspect_command(container_names)
        pipe(
          DockerCLI::Container::Inspect.build(container_names),
          [:jq, "-r", "'map({ Name: .Name, Id: .Id, State: .State, Config: { Labels: .Config.Labels }}) | tostring'"]
        )
      end

      def pipe(*commands)
        commands.reduce([]) do |combined, command|
          if combined.empty?
            command
          else
            combined += ["|"] unless combined.empty?
            combined + command.map(&:to_s)
          end
        end
      end
    end
  end
end
