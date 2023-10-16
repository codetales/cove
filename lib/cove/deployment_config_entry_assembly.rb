module Cove
  class DeploymentConfigEntryAssembly
    # @return [Cove::Deployment]
    attr_reader :deployment
    # @return [Cove::RoleConfig]
    attr_reader :config
    # @return [Cove::DeploymentConfigPathBuilder]
    attr_reader :path_builder
    # @return [Cove::DeploymentConfigVersionDigest]
    attr_reader :config_version_digest

    def initialize(deployment:, config:, path_builder:, config_version_digest:)
      @deployment = deployment
      @config = config
      @path_builder = path_builder
      @config_version_digest = config_version_digest
    end

    def make
      Cove::DeploymentConfigEntry.new(
        deployment: deployment,
        config_version_digest: config_version_digest,
        path_builder: path_builder,
        files: files
      )
    end

    private

    def files
      search_paths.find do |path|
        path.has_file?(config.source)
      end
    end

    def search_paths
      Cove::DeploymentConfigSearchPaths.new(deployment)
    end
  end
end
