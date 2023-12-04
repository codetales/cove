module Cove
  class Package
    attr_reader :deployment, :deployment_config

    delegate_missing_to :deployment

    def self.build(registry, role)
      deployment = Deployment.new(role)
      config = DeploymentConfig.prepare(registry, deployment)
      new(deployment, config)
    end

    def initialize(deployment, deployment_config)
      @deployment = deployment
      @deployment_config = deployment_config
    end

    def version
      Digest::SHA256.hexdigest([deployment.version, deployment_config.version].join("/"))[0..12]
    end

    def labels
      deployment.labels.merge({
        "cove.version" => version
      })
    end
  end
end
