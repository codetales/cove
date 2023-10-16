module Cove
  class DeploymentConfigEntry
    def initialize
    end

    def files
      [DeploymentConfigFile.new]
    end

    def host_path
    end
  end
end
