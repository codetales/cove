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

  describe "#containers_to_replace" do
    context "when no containers exist" do
      it "returns an empty list" do
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

    context "when the container already exists" do
      it "returns an empty list" do
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

        expect(state_diff.containers_to_replace).to eq([])
      end
    end

    context "when a container for a prior version exists" do
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

    context "when the containers for a prior version exist in a higher quantity" do
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

    context "when the containers for a prior version exists in a lower quantity" do
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
          ),
          Cove::DesiredContainer.new(
            name: "foo",
            image: "bar",
            version: "abc123",
            index: 2
          ),
          Cove::DesiredContainer.new(
            name: "foo",
            image: "bar",
            version: "abc123",
            index: 3
          )
        ]
        state_diff = described_class.new(existing_containers, desired_containers)

        expect(state_diff.containers_to_replace).to eq([
          {
            old: existing_containers.first,
            new: desired_containers.first
          },
          {
            old: existing_containers.second,
            new: desired_containers.second
          }
        ])
      end
    end
  end

  describe "#containers_to_stop" do
    context "when no containers exist" do
      it "returns an empty list" do
        existing_containers = []
        desired_containers = [
          Cove::DesiredContainer.new(
            name: "foo",
            image: "bar"
          )
        ]
        state_diff = described_class.new(existing_containers, desired_containers)

        expect(state_diff.containers_to_stop).to eq([])
      end
    end

    context "when the containers already exist" do
      it "returns an empty list" do
        existing_containers = [
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "running",
            role: "app",
            version: "abc123",
            index: 1
          ),
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "running",
            role: "app",
            version: "abc123",
            index: 2
          )
        ]
        desired_containers = [
          Cove::DesiredContainer.new(
            name: "foo",
            image: "bar",
            version: "abc123",
            index: 1
          ),
          Cove::DesiredContainer.new(
            name: "foo",
            image: "bar",
            version: "abc123",
            index: 2
          )
        ]
        state_diff = described_class.new(existing_containers, desired_containers)

        expect(state_diff.containers_to_stop).to eq([])
      end
    end

    context "when a container for a prior version exists" do
      it "returns an empty list" do
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

        expect(state_diff.containers_to_stop).to eq([])
      end
    end

    context "when the containers for a prior version exist in a higher quantity" do
      it "returns the containers to stop" do
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
          ),
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "running",
            role: "app",
            version: "abc122",
            index: 3
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

        expect(state_diff.containers_to_stop).to eq([existing_containers[1], existing_containers[2]])
      end
    end

    context "when containers for a prior version exists in a higher quantity or aren't running" do
      it "returns the container to stop" do
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
          ),
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "not running",
            role: "app",
            version: "abc122",
            index: 3
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

        expect(state_diff.containers_to_stop).to eq([existing_containers[1]])
      end
    end
  end

  describe "#containers_to_start" do
    context "when no containers exist" do
      it "returns an empty list" do
        existing_containers = []
        desired_containers = [
          Cove::DesiredContainer.new(
            name: "foo",
            image: "bar"
          )
        ]
        state_diff = described_class.new(existing_containers, desired_containers)

        expect(state_diff.containers_to_start).to eq([])
      end
    end

    context "when the container already exists and is running" do
      it "returns an empty list" do
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

        expect(state_diff.containers_to_start).to eq([])
      end
    end

    context "when the container already exists and isn't running" do
      it "returns the container to start" do
        existing_containers = [
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "not running",
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

        expect(state_diff.containers_to_start).to eq([desired_containers[0]])
      end
    end

    context "when a container for a prior version exists and isn't running" do
      it "returns an empty list" do
        existing_containers = [
          Cove::Runtime::Container.new(
            id: "123",
            name: "foo",
            image: "bar",
            status: "not running",
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

        expect(state_diff.containers_to_start).to eq([])
      end
    end
  end
end
