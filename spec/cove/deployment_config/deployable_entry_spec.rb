RSpec.describe Cove::DeploymentConfig::Entry do
  describe "#host_directories" do
    it "prepends the host directory to the path" do
      entry = Mocktail.of(Cove::DeploymentConfig::Entry)
      stubs { entry.name }.with { ["STUBBED_NAME"] }
      stubs { entry.directories }.with { ["some/path", "other"] }

      deployable_entry = Cove::DeploymentConfig::DeployableEntry.new(entry: entry, host_path: "/host/path")
      expect(deployable_entry.host_directories).to eq(["/host/path/STUBBED_NAME", "/host/path/STUBBED_NAME/some/path", "/host/path/STUBBED_NAME/other"])
    end
  end

  describe "#files" do
    it "prepends the host directory to the path" do
      entry = Mocktail.of(Cove::DeploymentConfig::Entry)
      file1 = Mocktail.of(Cove::DeploymentConfig::ConfigFile)
      file2 = Mocktail.of(Cove::DeploymentConfig::ConfigFile)

      stubs { entry.name }.with { ["STUBBED_NAME"] }
      stubs { entry.files }.with { [file1, file2] }
      stubs { file1.path }.with { "some/file.yml" }
      stubs { file2.path }.with { "other.yml" }

      deployable_entry = Cove::DeploymentConfig::DeployableEntry.new(entry: entry, host_path: "/host/path")
      expect(deployable_entry.files.map(&:host_path)).to eq(["/host/path/STUBBED_NAME/some/file.yml", "/host/path/STUBBED_NAME/other.yml"])
    end
  end
end
