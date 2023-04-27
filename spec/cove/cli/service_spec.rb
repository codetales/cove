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
      described_class.new.invoke(:up, ["nginx"])

      expect(Cove.output.string).to eq(
        "Starting nginx.test on host1\nStarting nginx.test on host2\n"
      )
    end
  end
end
