module Cove
  module Steps
    class PullImage
      include Callable

      attr_reader :connection, :image

      def initialize(connection, image)
        @connection = connection
        @image = image
      end

      def call
        connection.info "Pulling image #{image}"
        connection.execute(*Command::Builder.pull_image(image))
      end
    end
  end
end
