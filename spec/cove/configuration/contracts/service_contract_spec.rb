RSpec.describe Cove::Configuration::Contracts::ServiceContract do
  context "service" do
    it "succeeds when service name and image are filled" do
      contract = Cove::Configuration::Contracts::ServiceContract.new
      result = contract.call(service_name: "nginx", image: "nginx:1.23.4", roles: [{name: "rolename", container_count: "2"}])
      expect(result.success?).to eq(true)
    end

    it "fails when service name is not filled" do
      contract = Cove::Configuration::Contracts::ServiceContract.new
      result = contract.call(service_name: "", image: "nginx:1.23.4", roles: [{name: "rolename", container_count: 3}])
      expect(result.errors[:service_name]).to be_present
      expect(result.success?).to eq(false)
    end

    it "fails when image is not filled" do
      contract = Cove::Configuration::Contracts::ServiceContract.new
      result = contract.call(service_name: "nginx", image: "", roles: [{name: "rolename", container_count: 3}])
      expect(result.errors[:image]).to be_present
      expect(result.success?).to eq(false)
    end
  end

  context "roles" do
    it "fails when roles is empty" do
      contract = Cove::Configuration::Contracts::ServiceContract.new
      result = contract.call(service_name: "a", image: "b", roles: [])
      expect(result.errors[:roles]).to be_present
      expect(result.success?).to eq(false)
    end

    it "succeeds with multiple roles" do
      contract = Cove::Configuration::Contracts::ServiceContract.new
      result = contract.call(service_name: "nginx", image: "nginx:1.23.4", roles: [{name: "web1", container_count: "2"}, {name: "web2", container_count: "2"}])
      expect(result.success?).to eq(true)
    end

    context "name" do
      it "fails when a role does not have a name" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{container_count: 2}])
        expect(result.errors[:roles][0][:name]).to be_present
        expect(result.success?).to eq(false)
      end

      it "fails with duplicate role names" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "nginx", image: "nginx:1.23.4", roles: [{name: "web"}, {name: "web"}, {name: "web2"}])
        expect(result.errors[:roles][1][:name]).to be_present
        expect(result.success?).to eq(false)
      end
    end

    context "container_count" do
      it "succeeds when container_count is not included" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{name: "web"}])
        expect(result.success?).to eq(true)
      end

      it "fails when container_count is not an integer" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{name: "web", container_count: "abc"}])
        expect(result.errors[:roles][0][:container_count]).to be_present
        expect(result.success?).to eq(false)
      end
    end

    context "ingress" do
      it "succeeds when type is port" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{name: "web", ingress: [{type: "port", source: 8080, target: 80}]}])
        expect(result.success?).to eq(true)
      end

      it "succeeds when type is port_range" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{name: "web", container_count: 2, ingress: [{type: "port_range", source: [8080, 8081], target: 80}]}])
        expect(result.success?).to eq(true)
      end

      it "fails when type is not included" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{name: "web", ingress: [{source: [8080, 8081], target: 80}]}])
        expect(result.errors[:roles][0][:ingress][0][:type]).to be_present
        expect(result.success?).to eq(false)
      end

      it "fails when type is not port or port_range" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{name: "web", ingress: [{type: "something", source: [8080, 8081], target: 80}]}])
        expect(result.errors[:roles][0][:ingress][0][:type]).to be_present
        expect(result.success?).to eq(false)
      end

      it "fails when source is not included" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{name: "web", ingress: [{type: "port_range", target: 80}]}])
        expect(result.errors[:roles][0][:ingress][0][:source]).to be_present
        expect(result.success?).to eq(false)
      end

      it "fails when source is not an integer" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{name: "web", ingress: [{type: "port", source: "eighty", target: 80}]}])
        expect(result.errors[:roles][0][:ingress][0][:source]).to be_present
        expect(result.success?).to eq(false)
      end

      it "fails when source is not an array" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{name: "web", ingress: [{type: "port_range", source: 8080, target: 80}]}])
        expect(result.errors[:roles][0][:ingress][0][:source]).to be_present
        expect(result.success?).to eq(false)
      end

      it "fails when source is an array of non-integers" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{name: "web", ingress: [{type: "port_range", source: [8080, "abc"], target: 80}]}])
        expect(result.errors[:roles][0][:ingress][0][:source]).to be_present
        expect(result.success?).to eq(false)
      end

      it "fails when the size of the source array is less than the container count " do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{name: "web", container_count: 4, ingress: [{type: "port_range", source: [8080, 8081], target: 80}]}])
        expect(result.errors[:roles][0][:ingress][0][:source]).to be_present
        expect(result.success?).to eq(false)
      end

      it "fails when target is not included" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{name: "web", ingress: [{type: "port", source: 8080}]}])
        expect(result.errors[:roles][0][:ingress][0][:target]).to be_present
        expect(result.success?).to eq(false)
      end

      it "fails when target is not an integer" do
        contract = Cove::Configuration::Contracts::ServiceContract.new
        result = contract.call(service_name: "a", image: "b", roles: [{name: "web", ingress: [{type: "port", source: 8080, target: "abc"}]}])
        expect(result.errors[:roles][0][:ingress][0][:target]).to be_present
        expect(result.success?).to eq(false)
      end
    end
  end
end
