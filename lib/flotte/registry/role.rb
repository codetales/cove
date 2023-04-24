module Flotte
  class Registry
    class Role < Base
      # @param name [String]
      # @return [Flotte::Role]
      def [](name)
        super
      end

      # @return [Array<Flotte::Role>]
      def all
        super
      end
    end
  end
end
