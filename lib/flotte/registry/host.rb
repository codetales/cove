module Flotte
  class Registry
    class Host
      include Enumerable

      def initialize
        @hosts_by_name = {}
      end

      def add(host)
        @hosts_by_name[host.name] = host
      end

      def all
        @hosts_by_name.values
      end

      def each
        all.each
      end

      def [](name)
        @hosts_by_name[name]
      end
    end
  end
end
