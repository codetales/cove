module Cove
  class LabelsForEntity
    # @param [Cove::Entity] entity
    def initialize(entity)
      @entity = entity
    end

    # @return [Array]
    def to_a
      @entity.labels.map do |key, value|
        "label=#{key}=#{value}"
      end
    end
  end
end
