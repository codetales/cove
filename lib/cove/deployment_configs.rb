require "cove/deployment_config_renderer"

module Cove
  # Is this actually a role or service config?
  class DeploymentConfigs
    # @param [Cove::DeploymentConfigRenderer] registry
    attr_reader :renderer
    # @param [Cove::Deployment] deployment
    attr_reader :deployment

    def initialize(deployment, renderer)
      @deployment = deployment
      @renderer = renderer
    end

    # @return [String] The version of the configs
    def version
      # Combine all the rendered configs and hash them
      combined = deployment.configs.map do |config|
        renderer.call(config[:source])
      end
      Digest::SHA2.hexdigest(combined.join)
    end
  end
end
