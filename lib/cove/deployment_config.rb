module Cove
  class DeploymentConfig
    # @return [Array<Cove::DeploymentConfigEntry>]
    attr_reader :entries

    def initialize(entries:, digest:)
      @entries = entries
      @digest = digest
    end
  end
end
