RSpec.describe Cove::DeploymentConfigAssembly do
  describe "#make" do
    it "builds a deployment config collection" do
      deployment = Mocktail.of(Cove::Deployment)
      config_version_digest = Mocktail.of_next(Cove::DeploymentConfigVersionDigest)
      path_builder = Mocktail.of_next(Cove::DeploymentConfigPathBuilder)

      stubs { |_| deployment.configs }.with { [Cove::RoleConfig.new(source: "postgresql.conf", target: "/etc/postgres/postgresql.conf")] }
      stubs { |_| deployment.service_name }.with { "postgres" }
      stubs { |m| config_version_digest.append(m.is_a(Cove::DeploymentConfigFile)) }
      stubs { |_| config_version_digest.build }.with { "STUBBED_VERSION" }
      stubs { |m| path_builder.set("/var/lib/cove/configs/postgres/STUBBED_VERSION") }
      stubs { |m| path_builder.get }.with { "/var/lib/cove/configs/postgres/STUBBED_VERSION" }

      deployment_config_collection = described_class.new(deployment).make

      expect(deployment_config_collection.entries.size).to eq(1)
      expect(deployment_config_collection.entries.first).to be_a(Cove::DeploymentConfigEntry)
      expect(deployment_config_collection.entries.first.files.size).to eq(1)
    end
  end
end
