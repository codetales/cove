RSpec.describe Flotte::Initialization do
  describe "#perform" do
    it "adds all hosts to the registry" do
      registry = Flotte::Registry.new
      config_path = "spec/fixtures/configs/basic"

      expect { described_class.new(config_path, registry).perform }.to change(registry.hosts, :size).by(3)
    end

    it "loads the services to the registry" do
      registry = Flotte::Registry.new
      config_path = "spec/fixtures/configs/basic"

      expect { described_class.new(config_path, registry).perform }.to change(registry.services, :size).by(1)
    end
  end
end
