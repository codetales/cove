RSpec.describe Flotte::Registry::Host do
  describe "#add" do
    it "adds a host" do
      host = Flotte::Host.new(name: "foobar")
      registry = described_class.new

      expect {
        registry.add(host)
      }.to change { registry.all.size }.by(1)
      expect(registry.all).to include(host)
    end
  end

  describe "#[host]" do
    it "allows accessing hosts by their names" do
      host1 = Flotte::Host.new(name: "london")
      host2 = Flotte::Host.new(name: "paris")
      registry = described_class.new

      registry.add(host1)
      registry.add(host2)

      expect(registry["london"]).to eq(host1)
      expect(registry["paris"]).to eq(host2)
    end
  end
end
