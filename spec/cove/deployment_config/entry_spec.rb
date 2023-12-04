RSpec.describe Cove::DeploymentConfig::Entry do
  describe "#files" do
    it "lists all files for the given source" do
      registry = Mocktail.of(Cove::Registry)
      deployment = Mocktail.of(Cove::Deployment)
      resolver = Mocktail.of_next(Cove::DeploymentConfig::FileResolver)
      mock = Mocktail.of(Cove::DeploymentConfig::ConfigFile)

      stubs { deployment.directory }.with { "/some/path" }
      stubs { resolver.call(registry: registry, deployment: deployment, source: "/some/path/configs/postgresql.conf") }.with { [mock] }

      entry = described_class.new(
        registry: registry,
        deployment: deployment,
        name: "STUBBED_CONFIG_NAME",
        source: "configs/postgresql.conf",
        target: "/etc/postgres/postgresql.conf"
      )

      expect(entry.files).to eq([mock])
    end
  end

  describe "#base" do
    context "if the source is a file" do
      it "returns the filename as base" do
        registry = Mocktail.of(Cove::Registry)
        deployment = Mocktail.of(Cove::Deployment)
        resolver = Mocktail.of_next(Cove::DeploymentConfig::FileResolver)
        file1 = Cove::DeploymentConfig::ConfigFile.new(path: "postgresql.conf", content: "STUBBED CONTENT")

        allow(File).to receive(:file?).and_return(true)
        stubs { deployment.directory }.with { "/some/path" }
        stubs { resolver.call(registry: registry, deployment: deployment, source: "/some/path/configs/postgresql.conf") }.with { [file1] }

        entry = described_class.new(
          registry: registry,
          deployment: deployment,
          name: "STUBBED_CONFIG_NAME",
          source: "configs/postgresql.conf",
          target: "/etc/postgres/postgresql.conf"
        )

        expect(entry.base).to eq("postgresql.conf")
      end
    end

    context "if the source is a directory" do
      it "returns the root path as base" do
        registry = Mocktail.of(Cove::Registry)
        deployment = Mocktail.of(Cove::Deployment)
        resolver = Mocktail.of_next(Cove::DeploymentConfig::FileResolver)
        file1 = Cove::DeploymentConfig::ConfigFile.new(path: "postgresql.conf", content: "STUBBED CONTENT")

        stubs { deployment.directory }.with { "/some/path" }
        stubs { resolver.call(registry: registry, deployment: deployment, source: "/some/path/configs/postgres/") }.with { [file1] }

        entry = described_class.new(
          registry: registry,
          deployment: deployment,
          name: "STUBBED_CONFIG_NAME",
          source: "configs/postgres/",
          target: "/etc/postgres/"
        )

        expect(entry.base).to eq("/")
      end
    end
  end

  describe "digestables" do
    it "lists all files for the given source" do
      registry = Mocktail.of(Cove::Registry)
      deployment = Mocktail.of(Cove::Deployment)
      resolver = Mocktail.of_next(Cove::DeploymentConfig::FileResolver)
      file1 = Cove::DeploymentConfig::ConfigFile.new(path: "postgresql.conf", content: "STUBBED CONTENT")
      file2 = Cove::DeploymentConfig::ConfigFile.new(path: "pg_hba.conf", content: "MORE STUBBED CONTENT")

      stubs { deployment.directory }.with { "/some/path" }
      stubs { resolver.call(registry: registry, deployment: deployment, source: "/some/path/configs/postgres/") }.with { [file1, file2] }

      entry = described_class.new(
        registry: registry,
        deployment: deployment,
        name: "STUBBED_CONFIG_NAME",
        source: "configs/postgres/",
        target: "/etc/postgres/"
      )

      expect(entry.digestables).to eq(
        [
          ["STUBBED_CONFIG_NAME", "postgresql.conf", "STUBBED CONTENT"],
          ["STUBBED_CONFIG_NAME", "pg_hba.conf", "MORE STUBBED CONTENT"]
        ]
      )
    end
  end

  describe "directories" do
    context "when there are no subdirectories" do
      it "returns an empty list" do
        registry = Mocktail.of(Cove::Registry)
        deployment = Mocktail.of(Cove::Deployment)
        resolver = Mocktail.of_next(Cove::DeploymentConfig::FileResolver)
        file1 = Cove::DeploymentConfig::ConfigFile.new(path: "postgresql.conf", content: "STUBBED CONTENT")
        file2 = Cove::DeploymentConfig::ConfigFile.new(path: "pg_hba.conf", content: "MORE STUBBED CONTENT")

        stubs { deployment.directory }.with { "/some/path" }
        stubs { resolver.call(registry: registry, deployment: deployment, source: "/some/path/configs/postgres/") }.with { [file1, file2] }

        entry = described_class.new(
          registry: registry,
          deployment: deployment,
          name: "STUBBED_CONFIG_NAME",
          source: "configs/postgres/",
          target: "/etc/postgres/"
        )

        expect(entry.directories).to eq([])
      end
    end

    context "with subdirectories" do
      it "returns a list of all unique subdirectories" do
        registry = Mocktail.of(Cove::Registry)
        deployment = Mocktail.of(Cove::Deployment)
        resolver = Mocktail.of_next(Cove::DeploymentConfig::FileResolver)
        file1 = Cove::DeploymentConfig::ConfigFile.new(path: "some/file.conf", content: "")
        file2 = Cove::DeploymentConfig::ConfigFile.new(path: "some/other.conf", content: "")
        file3 = Cove::DeploymentConfig::ConfigFile.new(path: "and/a/nested/file.conf", content: "")

        stubs { deployment.directory }.with { "/some/path" }
        stubs { resolver.call(registry: registry, deployment: deployment, source: "/some/path/configs/something/") }.with { [file1, file2, file3] }

        entry = described_class.new(
          registry: registry,
          deployment: deployment,
          name: "STUBBED_CONFIG_NAME",
          source: "configs/something/",
          target: "/etc/foo/"
        )

        expect(entry.directories).to eq([
          "some", "and/a/nested"
        ])
      end
    end
  end
end
