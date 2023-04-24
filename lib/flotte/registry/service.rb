module Flotte
  class Registry
    class Service < Base
      # @param name [String]
      # @return [Flotte::Service]
      def [](name)
        super
      end

      # @return [Array<Flotte::Service>]
      def all
        super
      end
    end
  end
end
