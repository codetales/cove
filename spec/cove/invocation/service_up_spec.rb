RSpec.describe Cove::Invocation::ServiceUp do
  describe "#invoke" do
    context "with no existing containers" do
      it "should start a container" do
        registry, service = setup_environment

        invocation = described_class.new(registry: registry, service: service)

        stubs << stub_command(Cove::Command::Builder.list_containers_for_service(service)).with_stdout("").with_exit_status(0)
        stubs << stub_command(Cove::Command::Builder.start_container_for_role(role)).with_stdout("").with_exit_status(0)
        stubs << stub_command(Cove::Command::Builder.check_container_health(role)).with_stdout("").with_exit_status(0)

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

      [registry, service]
    end
  end
end
