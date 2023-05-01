RSpec.describe Cove::Command::Builder do
  describe ".pipe" do
    it "joins the commands with pipes" do
      command1 = [:docker, "container", "ls"]
      command2 = [:grep, "foo"]
      expect(described_class.pipe(command1, command2)).to eq([:docker, "container", "ls", "|", :grep, "foo"])
    end
  end

  describe(".xargs") do
    it "prefixes the command with xargs" do
      command = [:docker, "container", "ls"]
      expect(described_class.xargs(command)).to eq([:xargs, :docker, "container", "ls"])
    end
  end
end
