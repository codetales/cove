module Cove
  class Deployment
    # @return [Cove::Role] The role to deploy
    attr_reader :role
    # @return [Cove::Service] The service of the deployment
    delegate :service, to: :role
    # @return [Integer] The number of containers to deploy
    delegate :container_count, to: :role
    # @return [String] The name of the role of the deployment
    delegate :name, to: :role, prefix: true
    # @return [Hash] The environment variables for the deployment
    delegate :environment_variables, to: :role
    # @return [String] The image of the deployment
    delegate :image, to: :role

    # param [Cove::Role] role The role to deploy
    # param [String] version The version of the role to deploy. The version is calculated if non is given
    def initialize(role, version: nil)
      @role = role
      @version = version
    end

    # @return [String] The name of the service of the deployment
    def service_name
      service.name
    end

    # @return [String] The id of the service of the deployment
    def service_id
      service.id
    end

    # @return [String] The directory of the service related to this deployment
    def directory
      service.directory
    end

    # @returnn [Array[Hash]] The configs for the deployment
    def configs
      role.configs
    end

    # @return [String] The version of the deployment
    def version
      @version ||= build_version
    end

    # @return [Cove::EntityLabels] The labels of the deployment
    def labels
      role.labels.merge({
        "cove.deployed_version" => version
      })
    end

    private

    def build_version
      Digest::SHA2.hexdigest([role.id, role.image, role.command, role.environment_variables, role.ports, role.configs].to_json)[0..12]
    end
  end
end
