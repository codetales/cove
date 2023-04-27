RSpec.describe Flotte::Invocation::ServiceUp do
  describe "#invoke" do
    context "with no existing containers" do
      it "should start a container" do
        host = Flotte::Host.new(name: "1.1.1.1")
        service = Flotte::Service.new(name: "test", image: "nginx:latest")
        role = Flotte::Role.new(name: "test", service: service, hosts: [host])
        registry = Flotte::Registry.build(hosts: [host], services: [service], roles: [role])
        invocation = described_class.new(registry: registry, service: service)

        stub_command(/docker container ls/).with_stdout("").with_exit_status(0)
        stub = stub_command(/docker container run/).with_stdout("").with_exit_status(0)

        invocation.invoke

        expect(stub).to have_been_invoked
      end
    end

    context "with existing containers" do
      it "should first stop and then start containers" do
        host = Flotte::Host.new(name: "1.1.1.1")
        service = Flotte::Service.new(name: "test", image: "nginx:latest")
        role = Flotte::Role.new(name: "test", service: service, hosts: [host])
        registry = Flotte::Registry.build(hosts: [host], services: [service], roles: [role])
        invocation = described_class.new(registry: registry, service: service)

        stub_command(/docker container ls/).with_stdout("foobar").with_exit_status(0)
        stub = stub_command(/docker container stop foobar/).with_stdout("").with_exit_status(0)
        stub = stub_command(/docker container run/).with_stdout("").with_exit_status(0)

        invocation.invoke

        expect(stub).to have_been_invoked
      end
    end
  end
end
