RSpec.describe Cove::DeploymentConfig::ConfigFile do
  describe "#directory" do
    context "when the path is at the relative root" do
      it "returns nil" do
        file = described_class.new(path: "postgresql.conf", content: "")

        expect(file.directory).to eq(nil)
      end
    end

    context "when the path is in a subdirectory directory" do
      it "returns the path to the directory" do
        file = described_class.new(path: "config/postgres/postgresql.conf", content: "")

        expect(file.directory).to eq("config/postgres")
      end
    end
  end
end
