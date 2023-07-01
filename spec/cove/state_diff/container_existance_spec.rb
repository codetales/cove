RSpec.describe Cove::StateDiff::ContainerExistance do
  describe "#containers_to_create" do
    context "when no containers exist" do
      it "returns all desired containers" do
        existing_containers = []
        desired_containers = [
          Cove::DesiredContainer.new(
            name: "foo",
            image: "bar"
          )
        ]
        state_diff = described_class.new(existing_containers, desired_containers)

        expect(state_diff.containers_to_create).to eq(desired_containers)
      end
    end

    context "when the container already exists" do
      it "returns an empty list" do
        existing_containers = [
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "running",
            role: "app",
            version: "abc123"
          )
        ]
        desired_containers = [
          Cove::DesiredContainer.new(
            name: "foo",
            image: "bar",
            version: "abc123"
          )
        ]
        state_diff = described_class.new(existing_containers, desired_containers)

        expect(state_diff.containers_to_create).to eq([])
      end
    end

    context "when a container for a prior version exists" do
      it "returns the container to create" do
        existing_containers = [
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "running",
            role: "app",
            version: "abc122",
            index: 1
          )
        ]
        desired_containers = [
          Cove::DesiredContainer.new(
            name: "foo",
            image: "bar",
            version: "abc123",
            index: 1
          )
        ]
        state_diff = described_class.new(existing_containers, desired_containers)

        expect(state_diff.containers_to_create).to eq(desired_containers)
      end
    end
  end
end
