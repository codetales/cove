RSpec.describe Flotte::Configuration::Service do
  describe "#service" do
    it "builds a service based on the yaml file" do
      config_file = "spec/fixtures/services/nginx.yml"

      host1 = Flotte::Host.new(name: "host1")
      host2 = Flotte::Host.new(name: "host2")
      host_registry = Flotte::Registry::Host.new([host1, host2])

      config = described_class.new(config_file, host_registry).build
      service = config.service
      role = config.roles.first

      expect(role.service).to eq(service)
      expect(service.name).to eq("nginx")
      expect(service.image).to eq("nginx:1.23.4")
      expect(role.environment).to eq({
        "SOME_VAR" => true,
        "FOO" => "baz"
      })
      expect(role.hosts).to eq([host1, host2])
    end
  end
end
