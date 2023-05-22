module Cove
  module Command
    class Builder
      # @param [Cove::Service] service
      # @return [Array] The command to list and inspect the containers for the service
      def self.get_container_details_for_service(service)
        pipe(
          list_containers_for_service(service),
          xargs(inspect_containers)
        )
      end

      # @param [Cove::Service] service
      # @return [Array]
      def self.list_containers_matching(*filters)
        Docker::Container::List.build(all: true, format: "{{.Names}}", filter: filters.flatten)
      end

      # @param [Array] containers The name or id of the container(s) to inspect
      # @return [Array] The command to inspect the containers
      def self.inspect_containers(*containers)
        [:docker, "container", "inspect", *containers.flatten]
      end

      def self.start_container(*containers)
        [:docker, "container", "start", *containers.flatten]
      end

      # @param [String] containers The name or id of the container(s) to stop
      # @param [Integer] time
      def self.stop_container(*containers, time: nil)
        Docker::Container::Stop.build(containers.flatten, time: time)
      end

      # @param [String] containers The name or id of the container(s) to delete
      def self.delete_container(*containers)
        [:docker, "container", "rm", *containers.flatten]
      end

      # @param [Cove::DesiredContainer] config
      # @return [Array] The command to create the container
      def self.create_container(config)
        Docker::Container::Create.build(image: config.image, name: config.name, labels: config.labels, command: config.command)
      end

      # @param [String] image The image to pull
      # @return [Array] The command to pull the image
      def self.pull_image(image)
        [:docker, "image", "pull", image]
      end

      # @param [Array] commands The commands to pipe together
      # @return [Array] The commands joined by pipes
      def self.pipe(*commands)
        commands.reduce([]) do |combined, command|
          combined += ["|"] unless combined.empty?
          combined + command
        end
      end

      def self.xargs(command)
        [:xargs, *command]
      end
    end
  end
end
