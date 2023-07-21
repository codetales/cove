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

    context "with port mappings" do
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
  end
end
