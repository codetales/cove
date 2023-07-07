RSpec.describe Cove::Registry do
  describe "#roles_for_service" do
    it "returns the roles for the given service" do
      service = Cove::Service.new(name: "test-service", image: "test")
      role = Cove::Role.new(name: "test-role", service: service, hosts: [])
      registry = Cove::Registry.build(services: [service], roles: [role])

      expect(registry.roles_for_service(service)).to eq([role])
    end
  end
end
