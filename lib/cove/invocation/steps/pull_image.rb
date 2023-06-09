module Cove
  module Invocation
    module Steps
      class PullImage
        include Callable

        attr_reader :connection, :role

        def initialize(connection, role)
          @connection = connection
          @role = role
        end

        def call
          connection.info "Pulling image #{role.image}"
          connection.execute(*Command::Builder.pull_image(role.image))
        end
      end
    end
  end
end
