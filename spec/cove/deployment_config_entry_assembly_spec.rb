RSpec.describe Cove::DeploymentConfigEntryAssembly do
  describe "#make" do
    it "assembles a config entry" do
      deployment = Mocktail.of(Cove::Deployment)
      path_builder = Mocktail.of(Cove::DeploymentConfigPathBuilder)
      config_version_digest = Mocktail.of(Cove::DeploymentConfigVersionDigest)
      config = Cove::RoleConfig.new(
        source: "postgresql.conf",
        target: "/etc/postgresql.conf"
      )

      config_entry = described_class.new(
        deployment: deployment,
        config: config,
        path_builder: path_builder,
        config_version_digest: config_version_digest
      ).make

      expect(config_entry).to be_a(Cove::DeploymentConfigEntry)
      expect(config_entry.files.size).to eq(1)
      file = config_entry.files.first
      expect(file.host_path).to eq("/var/lib/cove/configs/postgres/STUBBED_VERSION/postgresql.conf")
      expect(file.source).to eq("services/postgres/configs/postgresql.conf")
    end
  end
end
