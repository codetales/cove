require_relative "registry/base"
require_relative "registry/host"
require_relative "registry/service"

module Flotte
  class Registry
    def hosts
      @hosts_registry ||= Flotte::Registry::Host.new
    end

    def services
      @services_registry ||= Flotte::Registry::Service.new
    end
  end
end
