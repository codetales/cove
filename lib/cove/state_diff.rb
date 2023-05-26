module Cove
  class StateDiff
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

    def containers_to_start
      @desired_containers.select do |desired_container|
        @existing_containers.any? do |existing_container|
          existing_container.index == desired_container.index &&
            existing_container.version == desired_container.version &&
            !existing_container.running?
        end
      end
    end

    def containers_to_replace
      @existing_containers.select do |existing_container|
        @desired_containers.any? do |desired_container|
          existing_container.version != desired_container.version &&
            existing_container.index == desired_container.index &&
            existing_container.running?
        end
      end.map do |existing_container|
        {
          old: existing_container,
          new: @desired_containers.find do |desired_container|
            existing_container.index == desired_container.index
          end
        }
      end
    end

    def containers_to_stop
      []
    end
  end
end
