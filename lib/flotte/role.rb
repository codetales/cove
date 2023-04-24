module Flotte
  class Role
    # @return [String]
    attr_reader :name, :environment
    # @return [Flotte::Service]
    attr_reader :service
    # @return [Array<Flotte::Host>]
    attr_reader :hosts
    # @return [String]
    delegate :image, to: :service

    def initialize(name:, service:, hosts:, environment: {})
      @name = name
      @service = service
      @environment = environment
      @hosts = hosts
    end

    # @return [String]
    def id
      "#{service.name}.#{name}"
    end
  end
end
