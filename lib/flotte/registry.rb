require_relative "registry/base"
require_relative "registry/host"
require_relative "registry/service"
require_relative "registry/role"

module Flotte
  class Registry
    def self.build(hosts: [], services: [], roles: [])
      registry = new
      registry.hosts.add(hosts)
      registry.services.add(services)
      registry.roles.add(roles)
      registry
    end

    # @return [Flotte::Registry::Host]
    def hosts
      @hosts_registry ||= Flotte::Registry::Host.new
    end

    # @return [Flotte::Registry::Service]
    def services
      @services_registry ||= Flotte::Registry::Service.new
    end

    # @return [Flotte::Registry::Role]
    def roles
      @roles_registry ||= Flotte::Registry::Role.new
    end
  end
end
