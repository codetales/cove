module Cove
  module StateDiff
    class ContainerStatus
      # @return [Array<Cove::Runtime::Container>]
      attr_reader :current_containers

      # @return [Array<Cove::DesiredContainer>]
      attr_reader :desired_containers

      # @param current_containers [Array<Cove::Runtime::Container>]
      # @param desired_containers [Array<Cove::DesiredContainer>]
      def initialize(current_containers, desired_containers)
        @current_containers = current_containers
        @desired_containers = desired_containers
      end

      def containers_to_start
        return [] unless desired_containers.count > current_containers.count

        desired_containers.select do |desired_container|
          current_containers.any? do |current_container|
            current_container.index == desired_container.index &&
              current_container.version == desired_container.version &&
              !current_container.running?
          end
        end
      end

      def containers_to_replace
        current_containers.select do |current_container|
          desired_containers.any? do |desired_container|
            current_container.version != desired_container.version &&
              current_container.index == desired_container.index &&
              current_container.running?
          end
        end.map do |current_container|
          {
            old: current_container,
            new: desired_containers.find do |desired_container|
              current_container.index == desired_container.index
            end
          }
        end
      end

      def containers_to_stop
        current_containers.reject do |current_container|
          desired_containers.any? do |desired_container|
            !current_container.running? ||
              (current_container.index == desired_container.index)
          end
        end
      end
    end
  end
end
