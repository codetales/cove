RSpec.describe Cove::StateDiff do
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

    context "when the containers already exist" do
      it "an empty list" do
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

    context "when a containers for a prior version exists" do
      it "an empty list" do
        existing_containers = [
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "running",
            role: "app",
            version: "abc122"
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

        expect(state_diff.containers_to_create).to eq(desired_containers)
      end
    end
  end

  describe "#containers_to_replace" do
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

        expect(state_diff.containers_to_replace).to eq([])
      end
    end

    context "when the containers already exist" do
      it "an empty list" do
        existing_containers = [
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "running",
            role: "app",
            version: "abc123",
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

        expect(state_diff.containers_to_replace).to eq(
          []
        )
      end
    end

    context "when a containers for a prior version exists" do
      it "returns the containers to replace" do
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

        expect(state_diff.containers_to_replace).to eq([
          {
            old: existing_containers.first,
            new: desired_containers.first
          }
        ])
      end
    end

    context "when a containers for a prior version exists in a higher quantity" do
      it "returns the containers to replace" do
        existing_containers = [
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "running",
            role: "app",
            version: "abc122",
            index: 1
          ),
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "running",
            role: "app",
            version: "abc122",
            index: 2
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

        expect(state_diff.containers_to_replace).to eq([
          {
            old: existing_containers.first,
            new: desired_containers.first
          }
        ])
      end
    end

    context "when a containers for a prior version exists in a higher quantity" do
      it "returns the containers to replace" do
        existing_containers = [
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "running",
            role: "app",
            version: "abc122",
            index: 1
          ),
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "running",
            role: "app",
            version: "abc122",
            index: 2
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

        expect(state_diff.containers_to_replace).to eq([
          {
            old: existing_containers.first,
            new: desired_containers.first
          }
        ])
      end
    end
  end
end
