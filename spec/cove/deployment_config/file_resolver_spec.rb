RSpec.describe Cove::DeploymentConfig::FileResolver do
  describe "#call" do
    context "when the source is a directory" do
      it "returns a list with one ConfigFile object per file in the directory" do
        registry = Cove::Registry.new
        deployment = Mocktail.of(Cove::Deployment)

        result = described_class.new.call(registry: registry, deployment: deployment, source: "spec/fixtures/deployment_configs//config_with_subdirectories_and_files")

        expect(result.map(&:path)).to eq(["abc/bar.conf", "foo.yml"])
      end
    end

    context "when the source is a file" do
      it "returns a list with one ConfigFile object for the given file" do
        registry = Cove::Registry.new
        deployment = Mocktail.of(Cove::Deployment)

        result = described_class.new.call(registry: registry, deployment: deployment, source: "spec/fixtures/deployment_configs/config_with_subdirectories_and_files/abc/bar.conf")

        expect(result.map(&:path)).to eq(["bar.conf"])
      end
    end

    context "when the path does not exist" do
      it "throws an exception" do
        registry = Cove::Registry.new
        deployment = Mocktail.of(Cove::Deployment)

        expect {
          described_class.new.call(registry: registry, deployment: deployment, source: "spec/fixtures/deployment_configs/does/not/exist.conf")
        }.to raise_error(Cove::DeploymentConfig::FileResolver::FileNotFound)
      end
    end

    context "rendering" do
      it "renders the file contents using the renderer" do
        registry = Cove::Registry.new
        deployment = Mocktail.of(Cove::Deployment)

        stubs { deployment.service_name }.with { "STUBBED NAME" }

        result = described_class.new.call(registry: registry, deployment: deployment, source: "spec/fixtures/deployment_configs/renderable_config.txt")
        expect(result.first.content).to eq("Hello STUBBED NAME")
      end
    end
  end
end
