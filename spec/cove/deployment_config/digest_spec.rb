RSpec.describe Cove::DeploymentConfig::Digest do
  describe "#for" do
    it "returns a digest for the deployment" do
      input = ["config-name", "path/to/file", "content"]

      digest = described_class.new

      expect(digest.for([input])).to eq(Digest::SHA2.hexdigest(input.join("")))
    end

    context "with unordered input" do
      it "returns a stable result" do
        input1 = ["config-name", "path/to/file1", "content1"]
        input2 = ["config-name", "path/to/file2", "content2"]
        input3 = ["second-config-name", "some/other/path", "content3"]

        digest = described_class.new

        expect(digest.for([input3, input1, input2])).to eq(digest.for([input1, input2, input3]))
        expect(digest.for([input2, input1])).to eq(digest.for([input1, input2]))
      end
    end
  end
end
