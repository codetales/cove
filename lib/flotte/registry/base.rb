module Flotte
  class Registry
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
        @entities_by_id[entity.id] = entity
      end

      def all
        @entities_by_id.values
      end

      def [](id)
        @entities_by_id[id]
      end
    end
  end
end
