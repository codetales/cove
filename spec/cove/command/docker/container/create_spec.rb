require "spec_helper"

RSpec.describe Cove::Command::Docker::Container::Create do
  describe ".build" do
    context "with an image and name" do
      it "returns the expected command" do
        expect(described_class.build(image: "hello-world", name: "my-container")).to eq(
          [
            :docker,
            "container",
            "create",
            "--name", "my-container",
            "hello-world"
          ]
        )
      end
    end

    context "with custom commands" do
      it "returns the expected command" do
        expect(described_class.build(image: "hello-world", name: "my-container", command: ["ping", "8.8.8.8"])).to eq(
          [
            :docker,
            "container",
            "create",
            "--name", "my-container",
            "hello-world",
            "ping", "8.8.8.8"
          ]
        )
      end
    end

    context "with a port mapping" do
      it "returns the expected command" do
        expect(described_class.build(image: "hello-world", name: "my-container", ports: [{"type" => "port", "source" => 8080, "target" => 80}])).to eq(
          [
            :docker,
            "container",
            "create",
            "--name", "my-container",
            "--publish", "8080:80",
            "hello-world"
          ]
        )
      end
    end

    context "with a port range" do
      it "returns the expected command" do
        expect(described_class.build(image: "hello-world", index: 1, name: "my-container", ports: [{"type" => "port_range", "source" => [8080, 8081], "target" => 80}])).to eq(
          [
            :docker,
            "container",
            "create",
            "--name", "my-container",
            "--publish", "8080:80",
            "hello-world"
          ]
        )
      end
    end

    context "with a mounted volume" do
      it "returns the expected command" do
        expect(described_class.build(image: "hello-world", name: "my-container", mounts: [{"type" => "volume", "source" => "my-awesome-volume", "target" => "/data"}])).to eq(
          [
            :docker,
            "container",
            "create",
            "--name", "my-container",
            "--mount", "type=volume,source=my-awesome-volume,target=/data",
            "hello-world"
          ]
        )
      end
    end
  end
end
