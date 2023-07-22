RSpec.describe Cove::Deployment do
  describe "#version" do
    context "when two roles have different custom commands" do
      it "creates different versions for each deployment" do
        role1 = setup_environment(command: ["foo"])
        role2 = setup_environment(command: ["bar"])
        deployment1 = Cove::Deployment.new(role1)
        deployment2 = Cove::Deployment.new(role2)
        expect(deployment1.version).not_to eq(deployment2.version)
      end
    end

    context "when one role has a custom command and one role does not" do
      it "creates different versions for each deployment" do
        role1 = setup_environment(command: ["foo"])
        role2 = setup_environment(command: [])
        deployment1 = Cove::Deployment.new(role1)
        deployment2 = Cove::Deployment.new(role2)
        expect(deployment1.version).not_to eq(deployment2.version)
      end
    end

    context "when two roles have the same custom commands" do
      it "creates the same version for each deployment" do
        role1 = setup_environment(command: ["foo"])
        role2 = setup_environment(command: ["foo"])
        deployment1 = Cove::Deployment.new(role1)
        deployment2 = Cove::Deployment.new(role2)
        expect(deployment1.version).to eq(deployment2.version)
      end
    end

    context "when two roles have no custom commands" do
      it "creates the same version for each deployment" do
        role1 = setup_environment(command: [])
        role2 = setup_environment(command: [])
        deployment1 = Cove::Deployment.new(role1)
        deployment2 = Cove::Deployment.new(role2)
        expect(deployment1.version).to eq(deployment2.version)
      end
    end

    context "when two roles have different port mappings" do
      it "creates different versions for each deployment" do
        role1 = setup_environment(ports: [{"type" => "port", "source" => 80, "target" => 80}])
        role2 = setup_environment(ports: [{"type" => "port", "source" => 20, "target" => 80}])
        deployment1 = Cove::Deployment.new(role1)
        deployment2 = Cove::Deployment.new(role2)
        expect(deployment1.version).not_to eq(deployment2.version)
      end
    end

    context "when two roles have the same port mappings" do
      it "creates the same version for each deployment" do
        role1 = setup_environment(ports: [{"type" => "port", "source" => 80, "target" => 80}])
        role2 = setup_environment(ports: [{"type" => "port", "source" => 80, "target" => 80}])
        deployment1 = Cove::Deployment.new(role1)
        deployment2 = Cove::Deployment.new(role2)
        expect(deployment1.version).to eq(deployment2.version)
      end
    end

    def setup_environment(service_name: "test", role_name: "web", image: "app:latest", command: [], ports: [])
      host = Cove::Host.new(name: "1.1.1.1")
      service = Cove::Service.new(name: service_name, image: image)
      role = Cove::Role.new(name: role_name, service: service, hosts: [host], command: command, ports: ports)
    end
  end
end
