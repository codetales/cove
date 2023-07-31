RSpec.describe Cove::Configuration::Service do
  describe "#service" do
    it "builds a service based on the yaml file" do
      config_file = "spec/fixtures/services/nginx.yml"

      host1 = Cove::Host.new(name: "host1")
      host2 = Cove::Host.new(name: "host2")
      host_registry = Cove::Registry::Host.new([host1, host2])

      config = described_class.new(config_file, host_registry).build
      service = config.service
      role = config.roles.first

      expect(role.service).to eq(service)
      expect(service.name).to eq("nginx")
      expect(service.image).to eq("nginx:1.23.4")
      expect(role.environment_variables).to eq({
        "SOME_VAR" => true,
        "FOO" => "baz"
      })
      expect(role.hosts).to eq([host1, host2])
    end
  end

  describe "#roles" do
    context "when the container count is provided in the yaml file" do
      it "builds a role based on the yaml file" do
        config_file = "spec/fixtures/configs/basic/services/nginx/service.yml"

        host1 = Cove::Host.new(name: "host1")
        host2 = Cove::Host.new(name: "host2")
        host_registry = Cove::Registry::Host.new([host1, host2])

        config = described_class.new(config_file, host_registry).build
        service = config.service
        role = config.roles.first

        expect(role.name).to eq("web")
        expect(role.service).to eq(service)
        expect(role.container_count).to eq(2)
        expect(role.environment_variables).to eq({
          "SOME_VAR" => true,
          "FOO" => "baz"
        })
        expect(role.hosts).to eq([host1, host2])
      end
    end

    context "when the container count is not provided in the yaml file" do
      it "builds a role based on the yaml file with a default container count of 1" do
        config_file = "spec/fixtures/services/nginx.yml"
        host1 = Cove::Host.new(name: "host1")
        host2 = Cove::Host.new(name: "host2")
        host_registry = Cove::Registry::Host.new([host1, host2])

        config = described_class.new(config_file, host_registry).build
        service = config.service
        role = config.roles.first

        expect(role.name).to eq("web")
        expect(role.service).to eq(service)
        expect(role.container_count).to eq(1)
        expect(role.environment_variables).to eq({
          "SOME_VAR" => true,
          "FOO" => "baz"
        })
        expect(role.hosts).to eq([host1, host2])
      end
    end

    context "when custom commands are provided in the yaml file" do
      it "builds a role based on the yaml file with the commands" do
        config_file = "spec/fixtures/services/service_with_commands.yml"
        host1 = Cove::Host.new(name: "host1")
        host2 = Cove::Host.new(name: "host2")
        host_registry = Cove::Registry::Host.new([host1, host2])

        config = described_class.new(config_file, host_registry).build
        service = config.service
        role = config.roles.first

        expect(role.name).to eq("web")
        expect(role.service).to eq(service)
        expect(role.container_count).to eq(1)
        expect(role.environment_variables).to eq({
          "SOME_VAR" => true,
          "FOO" => "baz"
        })
        expect(role.hosts).to eq([host1, host2])
        expect(role.command).to eq(["ping", "8.8.8.8"])
      end
    end

    context "when port mappings are provided in the yaml file" do
      it "builds a role based on the yaml file with the ports" do
        config_file = "spec/fixtures/services/service_with_commands.yml"
        host1 = Cove::Host.new(name: "host1")
        host2 = Cove::Host.new(name: "host2")
        host_registry = Cove::Registry::Host.new([host1, host2])

        config = described_class.new(config_file, host_registry).build
        service = config.service
        role = config.roles.first

        expect(role.name).to eq("web")
        expect(role.service).to eq(service)
        expect(role.container_count).to eq(1)
        expect(role.environment_variables).to eq({
          "SOME_VAR" => true,
          "FOO" => "baz"
        })
        expect(role.hosts).to eq([host1, host2])
        expect(role.command).to eq(["ping", "8.8.8.8"])
        expect(role.ports).to eq([{"type" => "port", "source" => 80, "target" => 80}])
      end
    end

    context "when a port range is provided in the yaml file" do
      it "builds a role based on the yaml file with the ports" do
        config_file = "spec/fixtures/services/service_with_port_range.yml"
        host1 = Cove::Host.new(name: "host1")
        host2 = Cove::Host.new(name: "host2")
        host_registry = Cove::Registry::Host.new([host1, host2])

        config = described_class.new(config_file, host_registry).build
        service = config.service
        role = config.roles.first

        expect(role.name).to eq("web")
        expect(role.service).to eq(service)
        expect(role.container_count).to eq(2)
        expect(role.environment_variables).to eq({
          "SOME_VAR" => true,
          "FOO" => "baz"
        })
        expect(role.hosts).to eq([host1, host2])
        expect(role.ports).to eq([{"type" => "port_range", "source" => [8080, 8081], "target" => 80}])
      end
    end

    context "when a volume to mount is provided in the yaml file" do
      it "builds a role based on the yaml file with the volume" do
        config_file = "spec/fixtures/services/service_with_mounted_volume.yml"
        host1 = Cove::Host.new(name: "host1")
        host2 = Cove::Host.new(name: "host2")
        host_registry = Cove::Registry::Host.new([host1, host2])

        config = described_class.new(config_file, host_registry).build
        service = config.service
        role = config.roles.first

        expect(role.name).to eq("web")
        expect(role.service).to eq(service)
        expect(role.hosts).to eq([host1, host2])
        expect(role.ports).to eq([{"type" => "port", "source" => 8080, "target" => 80}])
        expect(role.mounts).to eq([{"type" => "volume", "source" => "my-awesome-volume", "target" => "/data"}])
      end
    end
  end
end
