module Flotte
  class Registry
    class Host < Base
      # @param name [String]
      # @return [Flotte::Host]
      def [](name)
        super
      end

      # @return [Array<Flotte::Host>]
      def all
        super
      end
    end
  end
end
