module Cove
  module Runtime
    class ContainerStatus
      def self.running
        "running"
      end

      # TODO: Add more states
      # https://stackoverflow.com/questions/32427684/what-are-the-possible-states-for-a-docker-container
    end
  end
end
