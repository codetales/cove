module Cove
  class Initialization
    # @return [Cove::Registry]
    attr_reader :registry
    # @return [String]
    attr_reader :config_path

    # @param config_path [String]
    # @param registry [Cove::Registry]
    def initialize(config_path, registry)
      @config_path = config_path
      @registry = registry
    end

    def perform
      apply_settings
      init_hosts
      init_services
    end

    private

    def apply_settings
      # TODO: This is where we would apply settings from the config file
      # SSHKit.config.output = Airbrussh::Formatter.new(Cove.output)
    end

    def init_hosts
      host_config = Configuration::Hosts.new(File.join(config_path, "hosts.yml"))
      host_config.all.each do |host|
        registry.hosts.add(host)
      end
    end

    def init_services
      service_dirs = Dir[File.join(config_path, "services", "*/")]

      service_dirs.map do |service_dir|
        Configuration::Service.new(File.join(service_dir, "service.yml"), registry.hosts).build
      end.each do |service_config|
        registry.services.add(service_config.service)
        service_config.roles.each do |role|
          registry.roles.add(role)
        end
      end
    end
  end
end
