require "spec_helper"

RSpec.describe Cove::Command::Docker::Container::Run do
  describe ".build" do
    it "returns the expected command" do
      expect(described_class.build(image: "hello-world", name: "my-container")).to eq(
        [
          "docker",
          "container",
          "run",
          "--name", "my-container",
          "--detach",
          "hello-world"
        ]
      )
    end

    it "returns the expected command" do
      expect(described_class.build(image: "hello-world", name: "my-container", ports: [{"type" => "port", "source" => 8080, "target" => 80}])).to eq(
        [
          "docker",
          "container",
          "run",
          "--name", "my-container",
          "--publish", "8080:80",
          "--detach",
          "hello-world"
        ]
      )
    end

    it "returns the expected command" do
      expect(described_class.build(image: "hello-world", remove: true, detach: false, interactive: true, command: ["echo", "hello"])).to eq(
        [
          "docker",
          "container",
          "run",
          "--rm",
          "-it",
          "hello-world",
          "echo", "hello"
        ]
      )
    end
  end
end
