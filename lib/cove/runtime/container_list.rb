module Cove
  module Runtime
    class ContainerList
      include Enumerable

      delegate :each, :[], :last, :empty?, to: :@containers

      def initialize(containers = [])
        @containers = containers.to_a
      end

      def with_role(role)
        wrapped(select { |c| c.service == role.service.name && c.role == role.name })
      end

      def running
        wrapped(select { |c| c.running? })
      end

      private

      def wrapped(containers)
        self.class.new(containers)
      end
    end
  end
end
