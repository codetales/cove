module Cove
  class DeploymentConfigAssembly
    # @return [Cove::Deployment]
    attr_reader :deployment
    # @return [Cove::DeploymentConfigVersionDigest]
    attr_reader :config_version_digest
    # @return [Cove::DeploymentConfigPathBuilder]
    attr_reader :path_builder

    # @param deployment [Cove::Deployment]
    def initialize(deployment)
      @deployment = deployment
      @config_version_digest = DeploymentConfigVersionDigest.new
      @path_builder = DeploymentConfigPathBuilder.new
    end

    # @return [Cove::DeploymentConfig]
    def make
      DeploymentConfig.new(
        entries: entries,
        path_builder: path_builder,
        digest: config_version_digest
      )
    end

    private

    def entries
      deployment.configs.map do |config|
        DeploymentConfigEntryAssembly.new(
          deployment: deployment,
          config: config,
          path_builder: path_builder,
          config_version_digest: config_version_digest
        ).make
      end
    end
  end
end
