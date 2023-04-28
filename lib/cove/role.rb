module Cove
  class Role
    # @return [String]
    attr_reader :name, :environment
    # @return [Cove::Service]
    attr_reader :service
    # @return [Array<Cove::Host>]
    attr_reader :hosts
    # @return [Array<String>]
    attr_reader :command
    # @return [String]
    delegate :image, to: :service

    def initialize(name:, service:, hosts:, command: [], environment: {})
      @name = name
      @service = service
      @hosts = hosts
      @command = command
      @environment = environment
    end

    # @return [String]
    def id
      "#{service.name}.#{name}"
    end

    def name_for_container
      id + "." + SecureRandom.hex(4)
    end

    def labels
      service.labels.merge({
        "cove.role" => name
      })
    end
  end
end