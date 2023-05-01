module Cove
  module Invocation
    module Step
      class GetExistingContainerDetails
        def initialize(connection, service)
          connection.capture(*Command::Builder.list_containers_for_service(service), verbosity: Logger::INFO)
        end

        # # @param [Cove::Entity] entity
        # # @return [Array]
        # def self.filters_for_entity(entity)
        #   entity.labels.map do |key, value|
        #     "label=#{key}=#{value}"
        #   end
        # end
      end
    end
  end
end
