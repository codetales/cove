RSpec.describe Flotte::Configuration::Hosts do
  describe "#matching" do
    it "returns the configured hosts" do
      config = described_class.new("spec/fixtures/hosts/simple.yml")
      hosts = config.all
      expect(hosts.first.name).to eq("host1")
      expect(hosts.second.name).to eq("host2")
      expect(hosts.third.name).to eq("host3")
      expect(hosts.first.user).to eq("root")
      expect(hosts.second.user).to eq("ops")
      expect(hosts.third.user).to eq("root")
      expect(hosts.first.hostname).to eq("host1")
      expect(hosts.second.hostname).to eq("1.1.1.1")
      expect(hosts.third.hostname).to eq("host3")
    end
  end
end
