RSpec.describe Flotte::CLI::Service do
  describe "#list" do
    it "lists all services" do
      Flotte.init(config: "spec/fixtures/configs/basic/")
      described_class.new.invoke(:list)

      expect(Flotte.output.string).to eq(
        "nginx\n"
      )
    end
  end

  describe "#hosts" do
    it "lists all hosts for a given service" do
      Flotte.init(config: "spec/fixtures/configs/basic/")
      described_class.new.invoke(:hosts, ["nginx"])

      expect(Flotte.output.string).to eq(
        "host1\nhost2\n"
      )
    end
  end
end
