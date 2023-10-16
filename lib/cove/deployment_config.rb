module Cove
  class DeploymentConfig
    # @return [Array<Cove::DeploymentConfigEntry>]
    attr_reader :entries

    def initialize(entries:, digest:, path_builder:)
      @entries = entries
      @digest = digest
      @path_builder = path_builder
    end
  end
end
