require_relative "registry/host"

module Flotte
  class Registry
    def hosts
      @hosts_registry ||= Flotte::Registry::Host.new
    end
  end
end
