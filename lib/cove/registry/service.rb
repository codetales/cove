module Cove
  class Registry
    class Service < Base
      # @param name [String]
      # @return [Cove::Service]
      def [](name)
        super
      end

      # @return [Array<Cove::Service>]
      def all
        super
      end
    end
  end
end
