RSpec.describe Flotte::Configuration::Service do
  describe "#service" do
    it "builds a service based on the yaml file" do
      config_file = "spec/fixtures/services/nginx.yml"

      service = described_class.new(config_file).build

      expect(service.name).to eq("nginx")
      expect(service.image).to eq("nginx:1.23.4")
      expect(service.roles.size).to eq(1)
      expect(service.roles["web"]).to be_kind_of(Flotte::Service::Role)
      expect(service.roles["web"].environment).to eq({
        "SOME_VAR" => true,
        "FOO" => "baz",
      })
      expect(service.roles["web"].hosts).to eq("host1", "host2")
    end
  end
end
