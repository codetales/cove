RSpec.describe Cove::Invocation::ServiceUp do
  describe "#invoke" do
    context "with no existing containers" do
      it "should start a container" do
        registry, service, role = setup_environment(service_name: "test", role_name: "web", image: "app:latest")
        allow(Cove::Steps::GetExistingContainerDetails).to receive(:call).with(kind_of(SSHKit::Backend::Abstract), role) {
          Cove::Runtime::ContainerList.new([
            Cove::Runtime::Container.new(id: "1234", name: "legacy_container1", image: service.image, status: "running", service: service.name, role: role.name, version: "fake", index: 1),
            Cove::Runtime::Container.new(id: "4567", name: "legacy_container2", image: service.image, status: "running", service: service.name, role: role.name, version: "fake", index: 2)
          ])
        }

        stubs = []
        desired_container = Cove::DesiredContainer.from(role, 1)

        stubs << stub_command(/docker image pull app:latest/).with_exit_status(0)
        stubs << stub_command(/mkdir -p \/var\/cove\/env\/#{service.name}\/#{role.name}/)
        stubs << stub_command(/docker container create .* #{desired_container.name}/).with_exit_status(0)
        stubs << stub_command(/docker container stop legacy_container1/).with_exit_status(0)
        stubs << stub_command(/docker container stop legacy_container2/).with_exit_status(0)
        stubs << stub_command(/docker container start #{desired_container.name}/).with_exit_status(0)
        stubs << stub_upload("/var/cove/env/#{service.name}/#{role.name}/#{role.version}.env")

        invocation = described_class.new(registry: registry, service: service)

        invocation.invoke

        stubs.each { |stub| expect(stub).to have_been_invoked }
      end
    end

    # context "with existing containers" do
    #   it "should first stop and then start containers" do
    #     host = Cove::Host.new(name: "1.1.1.1")
    #     service = Cove::Service.new(name: "test", image: "nginx:latest")
    #     role = Cove::Role.new(name: "test", service: service, hosts: [host])
    #     registry = Cove::Registry.build(hosts: [host], services: [service], roles: [role])
    #     invocation = described_class.new(registry: registry, service: service)
    #
    #     stub_command(/docker container ls/).with_stdout("foobar").with_exit_status(0)
    #     stub = stub_command(/docker container stop foobar/).with_stdout("").with_exit_status(0)
    #     stub = stub_command(/docker container run/).with_stdout("").with_exit_status(0)
    #
    #     invocation.invoke
    #
    #     expect(stub).to have_been_invoked
    #   end
    # end

    def setup_environment(service_name: "test", role_name: "web", image: "app:latest")
      host = Cove::Host.new(name: "1.1.1.1")
      service = Cove::Service.new(name: service_name, image: image)
      role = Cove::Role.new(name: role_name, service: service, hosts: [host])
      registry = Cove::Registry.build(hosts: [host], services: [service], roles: [role])

      [registry, service, role]
    end
  end
end
