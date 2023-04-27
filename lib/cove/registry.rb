require_relative "registry/base"
require_relative "registry/host"
require_relative "registry/service"
require_relative "registry/role"

module Cove
  class Registry
    def self.build(hosts: [], services: [], roles: [])
      registry = new
      registry.hosts.add(hosts)
      registry.services.add(services)
      registry.roles.add(roles)
      registry
    end

    # @return [Cove::Registry::Host]
    def hosts
      @hosts_registry ||= Cove::Registry::Host.new
    end

    # @return [Cove::Registry::Service]
    def services
      @services_registry ||= Cove::Registry::Service.new
    end

    # @return [Cove::Registry::Role]
    def roles
      @roles_registry ||= Cove::Registry::Role.new
    end
  end
end
