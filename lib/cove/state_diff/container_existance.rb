module Cove
  class StateDiff
    class ContainerExistance
      def initialize(existing_containers, desired_containers)
        @existing_containers = existing_containers
        @desired_containers = desired_containers
      end

      def containers_to_create
        @desired_containers.reject do |desired_container|
          @existing_containers.any? do |existing_container|
            existing_container.index == desired_container.index &&
              existing_container.version == desired_container.version
          end
        end
      end
    end
  end
end
