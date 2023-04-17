RSpec.describe Flotte::Host do
  describe "#ssh_destination_string" do
    it "assembles the string from the username and hostname" do
      expect(described_class.new(name: "host1", user: "root").ssh_destination_string).to eq("root@host1")
      expect(described_class.new(name: "host1").ssh_destination_string).to eq("host1")
      expect(described_class.new(name: "host1", user: "root", hostname: "1.1.1.1").ssh_destination_string).to eq("root@1.1.1.1")
    end
  end
end
