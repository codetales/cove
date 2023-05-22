RSpec.describe Cove::Invocation::ServiceUp do
  describe "#invoke" do
    context "with no existing containers" do
      it "should start a container" do
        registry, service, role = setup_environment
        stubs = []
        desired_container = Cove::DesiredContainer.from(role, 1)
        stubs << stub_command(Cove::Command::Builder.pull_image(role.image)).with_exit_status(0)
        stubs << stub_command(Cove::Command::Builder.create_container(desired_container)).with_exit_status(0)
        stubs << stub_command(Cove::Command::Builder.stop_container("legacy_container2")).with_exit_status(0)
        stubs << stub_command(Cove::Command::Builder.stop_container("legacy_container1")).with_exit_status(0)
        stubs << stub_command(Cove::Command::Builder.start_container(desired_container.name)).with_exit_status(0)

        invocation = described_class.new(registry: registry, service: service)
        allow(Cove::Invocation::Steps::GetExistingContainerDetails).to receive(:call).with(kind_of(SSHKit::Backend::Abstract), service) {
          Cove::Runtime::ContainerList.new([
            Cove::Runtime::Container.new(id: "1234", name: "legacy_container1", image: service.image, status: "running", service: service.name, role: role.name, version: "fake", index: 1),
            Cove::Runtime::Container.new(id: "4567", name: "legacy_container2", image: service.image, status: "running", service: service.name, role: role.name, version: "fake", index: 2)
          ])
        }

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

    def setup_environment
      host = Cove::Host.new(name: "1.1.1.1")
      service = Cove::Service.new(name: "test", image: "nginx:latest")
      role = Cove::Role.new(name: "test", service: service, hosts: [host])
      registry = Cove::Registry.build(hosts: [host], services: [service], roles: [role])

      [registry, service, role]
    end
  end
end
