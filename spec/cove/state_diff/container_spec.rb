RSpec.describe Cove::StateDiff::Container do
  def verify(current_containers, desired_containers, output)
    state_diff = described_class.new(current_containers, desired_containers)
    expect(state_diff.instructions).to eq(output)
  end

  def build_desired_container(version, index)
    Cove::DesiredContainer.new(
      name: "foo-#{version}-#{index}",
      image: "bar",
      version: version,
      index: index
    )
  end

  def build_running_container(version, index)
    build_current_container(version, index, "running")
  end

  def build_stopped_container(version, index)
    build_current_container(version, index, "stopped")
  end

  def build_current_container(version, index, status)
    Cove::Runtime::Container.new(
      id: 1000 + index,
      name: "foo-#{version}-#{index}",
      image: "bar",
      role: "app",
      status: status,
      version: version,
      index: index
    )
  end

  describe "#instructions" do
    context "with matching versions" do
      context "when the there are more current containers than desired containers" do
        it "returns the instructions to stop the current container with the highest index" do
          current_containers = [
            build_running_container("v1", 1),
            build_running_container("v1", 2)
          ]
          desired_containers = [
            build_desired_container("v1", 1)
          ]

          output = [
            {action: :stop, container: current_containers[1].name}
          ]

          verify(current_containers, desired_containers, output)
        end
      end

      context "when some containers are not running" do
        it "returns the instructions to the start non running container" do
          current_containers = [
            build_running_container("v1", 1),
            build_stopped_container("v1", 2)
          ]
          desired_containers = [
            build_desired_container("v1", 1),
            build_desired_container("v1", 2)
          ]

          output = [
            {action: :start, container: desired_containers[1].name}
          ]

          verify(current_containers, desired_containers, output)
        end
      end
    end

    context "when the older version is running" do
      it "rolls all containers" do
        current_containers = [
          build_running_container("v1", 1),
          build_running_container("v1", 2),
          build_stopped_container("v2", 1),
          build_stopped_container("v2", 2)
        ]
        desired_containers = [
          build_desired_container("v2", 1),
          build_desired_container("v2", 2)
        ]

        output = [
          {action: :stop, container: current_containers[0].name},
          {action: :start, container: desired_containers[0].name},
          {action: :stop, container: current_containers[1].name},
          {action: :start, container: desired_containers[1].name}
        ]

        verify(current_containers, desired_containers, output)
      end
    end

    context "when there is a mix of older and newer version running" do
      it "rolls the older containers" do
        current_containers = [
          build_running_container("v1", 1),
          build_stopped_container("v1", 2),
          build_stopped_container("v2", 1),
          build_running_container("v2", 2)
        ]
        desired_containers = [
          build_desired_container("v2", 1),
          build_desired_container("v2", 2)
        ]

        output = [
          {action: :stop, container: current_containers[0].name},
          {action: :start, container: current_containers[2].name}
        ]

        verify(current_containers, desired_containers, output)
      end
    end

    context "when no containers are running" do
      it "starts all the desired containers" do
        current_containers = [
          build_stopped_container("v1", 1),
          build_stopped_container("v1", 2),
          build_stopped_container("v2", 1),
          build_stopped_container("v2", 2),
          build_stopped_container("v3", 1),
          build_stopped_container("v3", 2)
        ]
        desired_containers = [
          build_desired_container("v2", 1),
          build_desired_container("v2", 2)
        ]

        output = [
          {action: :start, container: desired_containers[0].name},
          {action: :start, container: desired_containers[1].name}
        ]

        verify(current_containers, desired_containers, output)
      end
    end

    context "when a desired container does not exist" do
      it "raises an error" do
        current_containers = [
          build_running_container("v1", 1)
        ]
        desired_containers = [
          build_desired_container("v1", 1),
          build_desired_container("v1", 2)
        ]

        expect do
          verify(current_containers, desired_containers, [])
        end.to raise_error(Cove::StateDiff::Container::Error)
      end
    end
  end
end
