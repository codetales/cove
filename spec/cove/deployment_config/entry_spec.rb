RSpec.describe Cove::DeploymentConfig::Entry do
  describe "#files" do
    it "lists all files for the given source" do
      registry = Mocktail.of(Cove::Registry)
      deployment = Mocktail.of(Cove::Deployment)
      resolver = Mocktail.of_next(Cove::DeploymentConfig::FileResolver)
      mock = Mocktail.of(Cove::DeploymentConfig::DeployableFile)

      stubs { resolver.call(registry: registry, deployment: deployment, source: "configs/postgresql.conf") }.with { [mock] }

      entry = described_class.new(
        registry: registry,
        deployment: deployment,
        name: "STUBBED_CONFIG_NAME",
        source: "configs/postgresql.conf",
        target: "/etc/postgres/postgresql.conf"
      )

      expect(entry.files).to eq([mock])
    end
  end
end
