module Cove
  class Registry
    class Host < Base
      # @param name [String]
      # @return [Cove::Host]
      def [](name)
        super
      end

      # @return [Array<Cove::Host>]
      def all
        super
      end
    end
  end
end
