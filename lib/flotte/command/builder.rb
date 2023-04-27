module Flotte
  module Command
    class Builder
      # @param [Flotte::Service] service
      # @return [Array]
      def self.list_containers_for_service(service)
        Docker::Container::List.build(all: true, format: "{{.Names}}", filter: filters_for_entity(service))
      end

      # @param [Flotte::Role] role
      # @return [Array]
      def self.list_containers_for_role(role)
        Docker::Container::List.build(all: true, format: "{{.Names}}", filter: filters_for_entity(role))
      end

      # @param [String] id_or_name
      # @param [Integer] time
      # @return [Array]
      def self.stop_container(id_or_name, time: nil)
        Docker::Container::Stop.build(id: id_or_name, time: time)
      end

      # @param [Flotte::Role] role
      # @return [Array]
      def self.start_container_for_role(role)
        Docker::Container::Run.build(image: role.image, name: role.name_for_container, labels: role.labels, command: role.command)
      end

      # @param [Flotte::Entity] entity
      # @return [Array]
      def self.filters_for_entity(entity)
        entity.labels.map do |key, value|
          "label=#{key}=#{value}"
        end
      end
    end
  end
end
