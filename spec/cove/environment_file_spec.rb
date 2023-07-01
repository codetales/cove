RSpec.describe Cove::EnvironmentFile do
  describe "#host_directory_path" do
    it "includes the service and role names" do
      service = Cove::Service.new(name: "foo", image: "app:latest")
      role = Cove::Role.new(name: "web", service: service, hosts: [])

      env = described_class.new(role)
      expect(env.host_directory_path).to eq("/var/cove/env/foo/web")
    end
  end

  describe "#host_file_path" do
    it "includes the version of the role" do
      service = Cove::Service.new(name: "foo", image: "app:latest")
      role = Cove::Role.new(name: "web", service: service, hosts: [])

      env = described_class.new(role)
      expect(env.host_file_path).to eq("/var/cove/env/foo/web/#{role.version}.env")
    end
  end

  describe "#content" do
    it "includes the environment variables" do
      service = Cove::Service.new(name: "foo", image: "app:latest")
      role = Cove::Role.new(name: "web", service: service, hosts: [], environment_variables: {
        "FOO" => "bar",
        "BAZ" => "qux"
      })

      env = described_class.new(role)
      expect(env.content).to eq(["FOO=bar", "BAZ=qux"].join("\n"))
    end
  end
end
