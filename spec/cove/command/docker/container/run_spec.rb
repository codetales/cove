require "spec_helper"

RSpec.describe Cove::Command::Docker::Container::Run do
  describe ".build" do
    it "returns the expected command" do
      expect(described_class.build(image: "hello-world", name: "my-container")).to eq(
        [
          :docker,
          "container",
          "run",
          "--name", "my-container",
          "hello-world"
        ]
      )
    end
  end
end
