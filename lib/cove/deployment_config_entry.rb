module Cove
  class DeploymentConfigEntry
    def initialize(deployment:, config_version_digest:, path_builder:, files:)
      @deployment = deployment
      @config_version_digest = config_version_digest
      @path_builder = path_builder
      @files = files
    end

    def files
      @files.map do |file|
        DeploymentConfigFile.new
      end
    end

    def host_path
    end
  end
end
