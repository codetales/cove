module Flotte
  class Registry
    class Base
      include Enumerable

      delegate :size, :each, to: :all

      def initialize
        @entities_by_name = {}
      end

      def add(host)
        @entities_by_name[host.name] = host
      end

      def all
        @entities_by_name.values
      end

      def [](name)
        @entities_by_name[name]
      end
    end
  end
end
