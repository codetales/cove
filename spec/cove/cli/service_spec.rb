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

  describe "#runCustom" do
    it "runs a container with a custom command" do
      Cove.init(config: "spec/fixtures/configs/basic/")

      expect(Kernel).to receive(:exec)
      described_class.new.invoke(:runCustom, ["nginx"], ["echo hello"])

      expect(Cove.output.string).to match(/nginx/)
      expect(Cove.output.string).to match(/web/)
      expect(Cove.output.string).to match(/host1/)
      expect(Cove.output.string).to match(/echo hello/)
    end
  end
end
