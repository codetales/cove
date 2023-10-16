module Cove
  class DeploymentConfigFile
    def host_path
      "/var/lib/cove/configs/postgres/STUBBED_VERSION/postgresql.conf"
    end

    def source
      "services/postgres/configs/postgresql.conf"
    end

    def content
    end
  end
end
