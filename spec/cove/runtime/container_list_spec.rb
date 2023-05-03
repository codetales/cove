RSpec.describe Cove::Runtime::ContainerList do
  describe "#for_role" do
    it "returns a list of containers for a given role" do
      service = Cove::Service.new(name: "foo", image: "app:latest")
      role = Cove::Role.new(name: "web", service: service, hosts: [])

      container1 = build_container(service: "foo", role: "web")
      container2 = build_container(service: "foo", role: "web")
      container3 = build_container(service: "bar", role: "web")

      result = described_class.new([container1, container2, container3]).for_role(role)
      expect(result).to be_kind_of(described_class)
      expect(result.count).to eq(2)
      expect(result).to include(container1, container2)
    end
  end

  describe "#running" do
    it "returns a list of containers for a given role" do
      container1 = build_container(status: "running")
      container2 = build_container(status: "stopped")
      container3 = build_container(status: "running")

      result = described_class.new([container1, container2, container3]).running
      expect(result).to be_kind_of(described_class)
      expect(result.count).to eq(2)
      expect(result).to include(container1, container3)
    end
  end

  def build_container(options)
    defaults = {
      "id" => "1234567890",
      "name" => "container_name",
      "image" => "app:latest",
      "status" => "running",
      "service" => "app",
      "role" => "web",
      "version" => Digest::SHA2.hexdigest("random")
    }
    params = defaults.merge(options.stringify_keys)
    Cove::Runtime::Container.new(params)
  end
end
