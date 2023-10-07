module Cove
  class Registry
    class InvalidEntity < StandardError; end

    class Base
      include Enumerable
      delegate :size, :each, to: :all

      def initialize(entities = [])
        @entities_by_id = {}
        Array(entities).each do |entity|
          add(entity)
        end
      end

      def add(entity)
        Array(entity).each do |entity|
          @entities_by_id[entity.id] = entity
        end
      end

      def all
        @entities_by_id.values
      end

      def [](id)
        @entities_by_id[id] || raise(InvalidEntity, "No #{entity_type} found for `#{id}`")
      end

      private

      def entity_type
        self.class.name.demodulize.downcase
      end
    end
  end
end
