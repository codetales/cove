module Cove
  class Role
    # @return [String] The name of the role
    attr_reader :name
    # @return [Hash<String, String>] The environment variables to set in the container
    attr_reader :environment_variables
    # @return [Cove::Service] The service this role belongs to
    attr_reader :service
    # @return [Array<Cove::Host>] The hosts this role should run on
    attr_reader :hosts
    # @return [Array<String>] The command to run in the container
    attr_reader :command
    # @return [Integer] The number of containers to run for this role
    attr_reader :container_count
    # @return [Array<Hash>] The ports to publish for the containers
    attr_reader :ports
    # @return [Array<Hash>] The volumes to mount into the containers
    attr_reader :mounts
    # @return [Array<Hash>] The configs to mount into the containers
    attr_reader :configs
    # @return [String] The image this role uses
    delegate :image, to: :service
    # @return [String] The name of the service this role belongs to
    delegate :name, to: :service, prefix: true

    def initialize(name:, service:, hosts:, container_count: 1, command: [], environment_variables: {}, ports: [], mounts: [], configs: {})
      @name = name
      @service = service
      @hosts = hosts
      @command = command
      @environment_variables = environment_variables
      @container_count = container_count || 1
      @ports = ports
      @mounts = mounts
      @configs = configs
    end

    # @return [String]
    def id
      "#{service.name}/#{name}"
    end

    # @return [Cove::EntityLabels] The labels for this role
    def labels
      service.labels.merge({
        "cove.role" => name
      })
    end
  end
end
