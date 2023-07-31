module Cove
  class Instance
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
    # @return [String] The command to run in the container
    delegate :command, to: :role
    # @return [Array<Hash>] The port mappings to run in the container
    delegate :ports, to: :role
    # @return [Array<Hash>] The volumes to mount to the container
    delegate :mounts, to: :role
    # @return [String] The image of the container
    delegate :image, to: :role

    # @param deployment [Cove::Deployment] The deployment the container is part of
    # @param index [Integer] The index of the container in the deployment
    def initialize(deployment, index)
      @deployment = deployment
      @index = index
    end

    def name
      "#{service.name}-#{role.name}-#{version}-#{index}"
    end

    # @return [Cove::EntityLabels] The labels of the container
    def labels
      deployment.labels.merge({
        "cove.index" => index.to_s
      })
    end
  end
end
