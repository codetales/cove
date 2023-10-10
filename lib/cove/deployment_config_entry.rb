module Cove
  class DeploymentConfigEntry
    def initialize(base_path)
    end

    def files
      [DeploymentConfigFile.new]
    end

    def host_path
    end
  end
end
