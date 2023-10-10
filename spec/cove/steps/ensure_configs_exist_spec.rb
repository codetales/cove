RSpec.describe Cove::Steps::EnsureConfigsExist do
  describe "#call" do
    it "uploads the configs to the host" do
      connection = SSHTestKit::Backend.new(Cove::Host.new(name: "host1").sshkit_host)
      deployment_config = Mocktail.of(Cove::DeploymentConfig)
      entry = Mocktail.of(Cove::DeploymentConfigEntry)
      file = Mocktail.of(Cove::DeploymentConfigFile)

      stubs { deployment_config.entries }.with { [entry] }
      stubs { entry.host_path }.with { "/var/cove/configs/abc/" }
      stubs { entry.files }.with { [file] }
      stubs { file.content }.with { "some content" }
      stubs { file.host_path }.with { "/var/cove/configs/abc/postgresql.conf" }

      mkdir_stub = stub_command(/#{Regexp.escape("mkdir -p /var/cove/configs/abc/ && chmod 700 /var/cove/configs/abc/")}/)
      upload_stub = stub_upload("/var/cove/configs/abc/postgresql.conf").on("host1")

      described_class.new(connection, deployment_config).call

      expect(mkdir_stub).to have_been_invoked
      expect(upload_stub).to have_been_invoked

      expect(SSHKit).to have_executed_command(mkdir_stub.command).on("host1")
      expect(SSHKit).to have_uploaded(upload_stub.destination).with_content(kind_of(String)).on("host1")
    end
  end
end
