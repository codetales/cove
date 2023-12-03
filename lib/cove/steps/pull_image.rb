module Cove
  module Steps
    class PullImage
      include Callable

      attr_reader :connection, :package

      def initialize(connection, package)
        @connection = connection
        @package = package
      end

      def call
        connection.info "Pulling image #{package.image}"
        connection.execute(*Command::Builder.pull_image(package.image))
      end
    end
  end
end
