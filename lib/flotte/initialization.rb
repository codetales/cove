module Flotte
  class Initialization
    def initialize(config_path, registry)
      @config_path = config_path
      @registry = registry
    end

    def perform
      init_hosts
      init_services
    end

    private

    def init_services
      service_dirs = Dir[File.join(@config_path, "services", "*/")]

      service_dirs.map do |service_dir|
        Flotte::Configuration::Service.new(File.join(service_dir, "service.yml"))
      end.each do |service_config|
        @registry.services.add(service_config.build)
      end
    end

    def init_hosts
      host_config = Flotte::Configuration::Hosts.new(File.join(@config_path, "hosts.yml"))
      host_config.all.each do |host|
        @registry.hosts.add(host)
      end
    end
  end
end
