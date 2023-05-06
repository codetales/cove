module Cove
  module Incovation
    module Steps
      class Roll
        attr_reader :connection, :role, :state_diff

        def initialize(connection, role, state_diff)
          @connection = connection
          @role = role
          @state_diff = state_diff
        end

        def call
          stop_extra_containers
          create_containers
          start_new_containers
          roll_containers
        end

        private

        def stop_extra_containers
          return unless state_diff.extra_containers.any?

          connection.info("Stopping #{state_diff.extra.count} extraneous containers")
          connection.execute(Command::Builder.stop_containers(state_diff.extra_containers.map(&:name)))
        end

        def create_containers
          return unless state_diff.containers_to_create.any?

          connection.info("Creating new containers")
          state_diff.containers_to_create.each do |container|
            connection.execute(Command::Builder.create_container(container))
          end
        end

        def start_new_containers
          return unless state_diff.container_additions.any?

          connection.info("Starting additional containers")
          state_diff.container_additions.each do |container|
            connection.execute(Command::Builder.start_container(container.name))

            # TODO: Wait for healthchecks
          end
        end

        def roll_containers
          return unless state_diff.containers_to_replace.any?

          connection.info("Rolling containers")
          state_diff.containers_to_replace.each do |running_container, desired_container|
            connection.info("Replacing #{running_container.name} with #{desired_container.name}")
            connection.execute(Command::Builder.stop_container(running_container.name))
            connection.execute(Command::Builder.start_container(desired_container.name))

            # TODO: Wait for healthchecks to pass
          end
        end
      end
    end
  end
end
