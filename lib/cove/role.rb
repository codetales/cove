module Cove
  class Role
    # @return [String]
    attr_reader :name, :environment_variables
    # @return [Cove::Service]
    attr_reader :service
    # @return [Array<Cove::Host>]
    attr_reader :hosts
    # @return [Array<String>]
    attr_reader :command
    # @return [String]
    delegate :image, to: :service

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

    def labels
      service.labels.merge({
        "cove.role" => name,
        "cove.deployed_version" => version
      })
    end

    def container_count
      1
    end

    def version
      hash
    end

    def hash
      Digest::SHA2.hexdigest([id, image, environment_variables].to_json)[0..12]
    end
  end
end
