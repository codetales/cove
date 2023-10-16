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

    # @param role [Cove::Role]
    # @return [Array<Cove::Host>]
    def hosts_for_service(service)
      hosts_for_roles(*roles_for_service(service))
    end

    # @param roles [Array<Cove::Role>]
    # @return [Array<Cove::Host>]
    def hosts_for_roles(*roles)
      roles.flatten.compact.flat_map(&:hosts).uniq.map { |hostname| hosts[hostname] }
    end

    # @param service [Cove::Service]
    # @return [Array<Cove::Role>]
    def roles_for_service(service)
      roles.select { |role| role.service == service }
    end
  end
end
