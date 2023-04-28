module Cove
  module Command
    class Builder
      # @param [Cove::Service] service
      # @return [Array]
      def self.list_containers_for_service(service)
        Docker::Container::List.build(all: true, format: "{{.Names}}", filter: filters_for_entity(service))
      end

      # @param [Cove::Role] role
      # @return [Array]
      def self.list_containers_for_role(role)
        Docker::Container::List.build(all: true, format: "{{.Names}}", filter: filters_for_entity(role))
      end

      # @param [String] containers The name or id of the container(s) to stop
      # @param [Integer] time
      def self.stop_container(containers, time: nil)
        Docker::Container::Stop.build(Array(containers), time: time)
      end

      # @param [String] containers The name or id of the container(s) to delete
      def self.delete_container(containers)
        Docker::Container::Rm.build(Array(containers ))
      end

      # @param [Cove::Role] role
      # @return [Array]
      def self.start_container_for_role(role)
        Docker::Container::Run.build(image: role.image, name: role.name_for_container, labels: role.labels, command: role.command)
      end

      # @param [Cove::Entity] entity
      # @return [Array]
      def self.filters_for_entity(entity)
        entity.labels.map do |key, value|
          "label=#{key}=#{value}"
        end
      end
    end
  end
end
