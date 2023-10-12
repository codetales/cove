module Cove
  class OnDemandInstance
    # @return [Cove::Deployment]
    attr_reader :deployment
    # @return [Integer]
    attr_reader :index
    # @return [Cove::Role]
    delegate :role, to: :deployment
    # @return [Cove::Service]
    delegate :service, to: :role
    # @return [String] The version of the deployment
    delegate :version, to: :deployment
    # @return [Array<String>] The command to run in the container
    attr_reader :command
    # @return [Array<Hash>] The port mapping to run in the container
    attr_reader :ports
    # @return [Array<Hash>] The volumes to mount to the container
    delegate :mounts, to: :role
    # @return [String] The image of the container
    delegate :image, to: :role
    # @return [Cove::EntityLabels] The labels of the container
    delegate :labels, to: :deployment

    # @param deployment [Cove::Deployment] The deployment the container is part of
    # @param command [Array<String>] The custom command to run in the container
    def initialize(deployment, command)
      @deployment = deployment
      @command = command
      @ports = []
      @index = 1
    end

    # @return [String]
    def name
      "#{service.name}-#{role.name}-#{version}-run-#{SecureRandom.hex(3)}"
    end

    # @return [Cove::EntityLabels] The labels of the container
    def labels
      deployment.labels.merge({
        "cove.type" => "on-demand"
      })
    end
  end
end
