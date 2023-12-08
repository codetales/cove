RSpec.describe Cove::Steps::EnsureConfigsExist do
  describe "#call" do
    it "renders and uploads the configs to the host" do
      ssh_host = Cove::Host.new(name: "host1").sshkit_host
      connection = SSHTestKit::Backend.new(ssh_host)

      deployment_config = Mocktail.of(Cove::DeploymentConfig)
      file = Mocktail.of(Cove::DeploymentConfig::DeployableFile)

      stubs { deployment_config.base_directory }.with { "/var/cove/configs/SERVICE_NAME/STUBBED_VERSION" }
      stubs { deployment_config.host_directories }.with { ["/var/cove/configs/SERVICE_NAME/STUBBED_VERSION/postgres"] }
      stubs { deployment_config.files }.with { [file] }
      stubs { file.content }.with { "some content" }
      stubs { file.host_path }.with { "/var/cove/configs/SERVICE_NAME/STUBBED_VERSION/postgres/postgresql.conf" }

      mkdir_config_stub = stub_command(/#{Regexp.escape("mkdir -p /var/cove/configs/SERVICE_NAME/STUBBED_VERSION && chmod 700 /var/cove/configs/SERVICE_NAME/STUBBED_VERSION")}/)
      mkdir_entry_stub = stub_command(/#{Regexp.escape("mkdir -p /var/cove/configs/SERVICE_NAME/STUBBED_VERSION/postgres && chmod 777 /var/cove/configs/SERVICE_NAME/STUBBED_VERSION/postgres")}/)
      upload_stub = stub_upload("/var/cove/configs/SERVICE_NAME/STUBBED_VERSION/postgres/postgresql.conf").on("host1")

      described_class.new(connection, deployment_config).call

      expect(SSHKit).to have_executed_command(mkdir_config_stub.command).on(ssh_host)
      expect(SSHKit).to have_executed_command(mkdir_entry_stub.command).on(ssh_host)
      expect(SSHKit).to have_uploaded(upload_stub.destination).with_content("some content").on(ssh_host)
    end
  end
end
