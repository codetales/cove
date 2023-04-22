require_relative "registry/base"
require_relative "registry/host"
require_relative "registry/service"
require_relative "registry/role"

module Flotte
  class Registry
    # @return [Flotte::Registry::Host]
    def hosts
      @hosts_registry ||= Flotte::Registry::Host.new
    end

    def services
      @services_registry ||= Flotte::Registry::Service.new
    end

    def roles
      @roles_registry ||= Flotte::Registry::Role.new
    end
  end
end
