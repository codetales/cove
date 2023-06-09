# frozen_string_literal: true

RSpec.describe Cove::CLI::Host do
  describe "#list" do
    it "prints a list of hosts from the config" do
      Cove.init(config: "spec/fixtures/configs/basic/")
      described_class.new.invoke(:list)

      expect(Cove.output.string).to eq(
        "host1\nhost2\nhost3\n"
      )
    end
  end

  describe "#ssh" do
    it "connects to a host via ssh" do
      Cove.init(config: "spec/fixtures/configs/basic/")

      expect(Kernel).to receive(:exec).with("ssh", "-t", "root@host1")
      described_class.new.invoke(:ssh, ["host1"])
    end
  end
end
