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
    # @return [String] The image this role uses
    delegate :image, to: :service
    # @return [String] The name of the service this role belongs to
    delegate :name, to: :service, prefix: true

    # @param name [String] The name of the role
    # @param service [Cove::Service] The service this role belongs to
    # @param hosts [Array<Cove::Host>] The hosts this role should run on
    # @param command [Array<String>] The command to run in the container
    # @param environment_variables [Hash<String, String>] The environment variables to set in the containers for this role
    def initialize(name:, service:, hosts:, command: [], environment_variables: {})
      @name = name
      @service = service
      @hosts = hosts
      @command = command
      @environment_variables = environment_variables
    end

    # @return [String]
    def id
      "#{service.name}.#{name}"
    end

    # @return [Cove::EntityLabels] The labels for this role
    def labels
      service.labels.merge({
        "cove.role" => name
      })
    end

    # @return [Integer] The number of containers to run for this role
    def container_count
      1
    end
  end
end
