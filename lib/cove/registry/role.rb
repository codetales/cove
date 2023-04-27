module Cove
  class Registry
    class Role < Base
      # @param name [String]
      # @return [Cove::Role]
      def [](name)
        super
      end

      # @return [Array<Cove::Role>]
      def all
        super
      end
    end
  end
end
