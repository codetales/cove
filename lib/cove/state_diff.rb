module Cove
  class StateDiff
    def initialize(existing_containers, desired_containers)
      @existing_containers = existing_containers
      @desired_containers = desired_containers
    end

    def containers_to_create
    end

    def containers_to_replace
    end

    def extra_containers
      @existing_containers[desired_containers.count..]
    end
  end
end
