RSpec.describe Cove::DeploymentConfig do
  describe "#base_directory" do
    it "returns the base directory for the deployment config containing the service name and version" do
      deployment = Mocktail.of(Cove::Deployment)
      entry = Mocktail.of(Cove::DeploymentConfig::Entry)
      stubs { deployment.service_name }.with { "STUBBED_SERVICE_NAME" }
      stubs { entry.name }.with { "STUBBED_CONFIG_NAME" }
      stubs { entry.directories }.with { ["/foo"] }

      deployment_config = described_class.new(deployment: deployment, entries: [entry], version: "STUBBED_VERSION")

      expect(deployment_config.base_directory).to eq("#{Cove.host_base_dir}/configs/STUBBED_SERVICE_NAME/STUBBED_VERSION")
    end
  end

  describe "#host_directories" do
    it "returns all the directories that need to be created" do
      deployment = Mocktail.of(Cove::Deployment)
      entry = Mocktail.of(Cove::DeploymentConfig::Entry)
      stubs { deployment.service_name }.with { "STUBBED_SERVICE_NAME" }
      stubs { entry.name }.with { "STUBBED_CONFIG_NAME" }
      stubs { entry.directories }.with { ["/foo"] }

      deployment_config = described_class.new(deployment: deployment, entries: [entry], version: "STUBBED_VERSION")

      expect(deployment_config.host_directories).to eq([
        "#{Cove.host_base_dir}/configs/STUBBED_SERVICE_NAME/STUBBED_VERSION/STUBBED_CONFIG_NAME",
        "#{Cove.host_base_dir}/configs/STUBBED_SERVICE_NAME/STUBBED_VERSION/STUBBED_CONFIG_NAME/foo"
      ])
    end
  end

  describe "#files" do
    it "returns a list of files that can be deployed" do
      deployment = Mocktail.of(Cove::Deployment)
      entry = Mocktail.of(Cove::DeploymentConfig::Entry)
      file = Mocktail.of(Cove::DeploymentConfig::ConfigFile)
      stubs { deployment.service_name }.with { "STUBBED_SERVICE_NAME" }
      stubs { entry.name }.with { "STUBBED_CONFIG_NAME" }
      stubs { entry.files }.with { [file] }
      stubs { file.path }.with { "postgresql.conf" }

      deployment_config = described_class.new(deployment: deployment, entries: [entry], version: "STUBBED_VERSION")

      expect(deployment_config.files.map(&:host_path)).to eq(["#{Cove.host_base_dir}/configs/STUBBED_SERVICE_NAME/STUBBED_VERSION/STUBBED_CONFIG_NAME/postgresql.conf"])
    end
  end

  describe ".prepare" do
    it "prepares the config files and builds a deployment config" do
      deployment = Mocktail.of(Cove::Deployment)
      digest = Mocktail.of_next(Cove::DeploymentConfig::Digest)

      stubs { |m| digest.for(m.any) }.with { ["STUBBED_VERSION"] }
      stubs { deployment.service_name }.with { "STUBBED_SERVICE_NAME" }
      stubs { deployment.directory }.with { "spec/fixtures/deployment_configs/postgres" }
      stubs { deployment.configs }.with { {"STUBBED_CONFIG_NAME" => {source: "postgresql.conf", target: "/etc/postgres/postgresql.conf"}} }

      deployment_config = described_class.prepare(Cove::Registry.new, deployment)

      expect(deployment_config.entries.count).to eq(1)
      expect(deployment_config.entries.first.files.map(&:host_path)).to eq(["#{Cove.host_base_dir}/configs/STUBBED_SERVICE_NAME/STUBBED_VERSION/STUBBED_CONFIG_NAME/postgresql.conf"])
    end
  end
end
