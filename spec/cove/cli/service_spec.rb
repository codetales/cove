RSpec.describe Cove::CLI::Service do
  describe "#list" do
    it "lists all services" do
      Cove.init(config: "spec/fixtures/configs/basic/")
      described_class.new.invoke(:list)

      expect(Cove.output.string).to eq(
        "nginx\n"
      )
    end
  end

  describe "#hosts" do
    it "lists all hosts for a given service" do
      Cove.init(config: "spec/fixtures/configs/basic/")
      described_class.new.invoke(:hosts, ["nginx"])

      expect(Cove.output.string).to eq(
        "host1\nhost2\n"
      )
    end
  end

  describe "#up" do
    it "spins up a service" do
      Cove.init(config: "spec/fixtures/configs/basic/")

      expect(Cove::Invocation::ServiceUp).to receive(:new).with(
        registry: Cove.registry,
        service: Cove.registry.services["nginx"]
      ) { double(invoke: nil) }
      described_class.new.invoke(:up, ["nginx"])
    end
  end

  describe "#run_custom" do
    it "runs a container with a custom command" do
      Cove.init(config: "spec/fixtures/configs/basic/")
      service = Cove.registry.services["nginx"]
      role = Cove.registry.roles_for_service(service).first
      host = role.hosts.first

      expect(Cove::Invocation::ServiceRun).to receive(:new).with(
        registry: Cove.registry,
        service: service,
        custom_cmd: ["echo", "hello"],
        role: role,
        host: host
      ) { double(invoke: nil) }
      described_class.new.invoke(:run_custom, ["nginx"], ["echo hello"])
    end
    it "runs a container with a custom command with a specified host" do
      Cove.init(config: "spec/fixtures/configs/basic/")
      service = Cove.registry.services["nginx"]
      role = Cove.registry.roles_for_service(service).first
      host = role.hosts.second

      expect(Cove::Invocation::ServiceRun).to receive(:new).with(
        registry: Cove.registry,
        service: service,
        custom_cmd: ["echo", "hello"],
        role: role,
        host: host
      ) { double(invoke: nil) }
      described_class.new.invoke(:run_custom, ["nginx", "echo hello"], host: "host2")
    end
  end
end
