module Cove
  module Steps
    class PullImage
      include Callable

      attr_reader :connection, :deployment

      def initialize(connection, deployment)
        @connection = connection
        @deployment = deployment
      end

      def call
        connection.info "Pulling image #{deployment.image}"
        connection.execute(*Command::Builder.pull_image(deployment.image))
      end
    end
  end
end
