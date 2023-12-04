RSpec.describe Cove::Invocation::ServiceUp do
  # TODO: Rewrite this test to be a full integration test, delete the others
  # Instead test the individual steps
  describe "#invoke" do
    before do
      allow_any_command!
      allow_any_upload!
    end

    context "with no existing containers" do
      it "should start a container" do
        registry, service, role = setup_environment(service_name: "test", role_name: "web", image: "app:latest", command: ["ping", "8.8.8.8"], ports: [{"type" => "port", "source" => 8080, "target" => 80}], mounts: [{"type" => "volume", "source" => "my-volume", "target" => "/data"}])

        package = Cove::Package.build(registry, role)
        instance = Cove::Instance.new(package, 1)

        desired_container = Cove::DesiredContainer.from(instance)

        allow(Cove::Steps::GetExistingContainerDetails).to receive(:call).with(kind_of(SSHKit::Backend::Abstract), kind_of(Cove::Package)) {
          Cove::Runtime::ContainerList.new([
            Cove::Runtime::Container.new(id: "1234", name: "legacy_container1", image: service.image, status: "running", service: service.name, role: role.name, version: "fake", index: 1),
            Cove::Runtime::Container.new(id: "4567", name: "legacy_container2", image: service.image, status: "running", service: service.name, role: role.name, version: "fake", index: 2)
          ])
        }.once

        allow(Cove::Steps::GetExistingContainerDetails).to receive(:call).with(kind_of(SSHKit::Backend::Abstract), kind_of(Cove::Role)) {
          Cove::Runtime::ContainerList.new([
            Cove::Runtime::Container.new(id: "1111", name: "legacy_container1", image: service.image, status: "running", service: service.name, role: role.name, version: "fake", index: 1),
            Cove::Runtime::Container.new(id: "1112", name: "legacy_container2", image: service.image, status: "running", service: service.name, role: role.name, version: "fake", index: 2),
            Cove::Runtime::Container.new(id: "9991", name: desired_container.name, image: service.image, status: "created", service: service.name, role: role.name, version: package.version, index: 1)
          ])
        }

        stubs = []
        stubs << stub_command(/docker image pull app:latest/).with_exit_status(0)
        stubs << stub_command(/mkdir -p #{File.join(Cove.host_base_dir, "env", service.name, role.name)}/)
        stubs << stub_command(/docker container create .* #{desired_container.name}.* --publish 8080:80 --mount type=volume,source=my-volume,target=\/data .* ping 8.8.8.8/).with_exit_status(0)
        stubs << stub_command(/docker container stop legacy_container1/).with_exit_status(0)
        stubs << stub_command(/docker container stop legacy_container2/).with_exit_status(0)
        stubs << stub_command(/docker container start #{desired_container.name}/).with_exit_status(0)
        stubs << stub_upload(File.join(Cove.host_base_dir, "env", service.name, role.name, "#{package.version}.env"))

        invocation = described_class.new(registry: registry, service: service)

        invocation.invoke

        stubs.each { |stub| expect(stub).to have_been_invoked }
      end

      # it "should start multiple containers" do
      #   registry, service, role = setup_environment(service_name: "test", role_name: "web", image: "app:latest", container_count: 2)
      #   deployment = Cove::Deployment.new(role)
      #   instance1 = Cove::Instance.new(deployment, 1)
      #   instance2 = Cove::Instance.new(deployment, 2)
      #   # TODO: This is invoked twice with different arguments. Should we stub them individually?
      #   allow(Cove::Steps::GetExistingContainerDetails).to receive(:call).with(kind_of(SSHKit::Backend::Abstract), anything) {
      #     Cove::Runtime::ContainerList.new([
      #       Cove::Runtime::Container.new(id: "1234", name: "legacy_container1", image: service.image, status: "running", service: service.name, role: role.name, version: "fake", index: 1),
      #       Cove::Runtime::Container.new(id: "4567", name: "legacy_container2", image: service.image, status: "running", service: service.name, role: role.name, version: "fake", index: 2)
      #     ])
      #   }

      #   stubs = []
      #   desired_container1 = Cove::DesiredContainer.from(instance1)
      #   desired_container2 = Cove::DesiredContainer.from(instance2)

      #   stubs << stub_command(/docker image pull app:latest/).with_exit_status(0)
      #   stubs << stub_command(/mkdir -p #{File.join(Cove.host_base_dir, "env", service.name, role.name)}/)
      #   stubs << stub_command(/docker container create .* #{desired_container1.name}/).with_exit_status(0)
      #   stubs << stub_command(/docker container create .* #{desired_container2.name}/).with_exit_status(0)
      #   stubs << stub_command(/docker container stop legacy_container1/).with_exit_status(0)
      #   stubs << stub_command(/docker container stop legacy_container2/).with_exit_status(0)
      #   stubs << stub_command(/docker container start #{desired_container1.name}/).with_exit_status(0)
      #   stubs << stub_command(/docker container start #{desired_container2.name}/).with_exit_status(0)
      #   stubs << stub_upload(File.join(Cove.host_base_dir, "env", service.name, role.name, "#{deployment.version}.env"))

      #   invocation = described_class.new(registry: registry, service: service)

      #   invocation.invoke

      #   stubs.each { |stub| expect(stub).to have_been_invoked }
      # end
      # it "should start multiple containers with port mappings" do
      #   registry, service, role = setup_environment(service_name: "test", role_name: "web", image: "app:latest", container_count: 2, ports: [{"type" => "port_range", "source" => [8080, 8081], "target" => 80}])
      #   deployment = Cove::Deployment.new(role)
      #   instance1 = Cove::Instance.new(deployment, 1)
      #   instance2 = Cove::Instance.new(deployment, 2)
      #   # TODO: This is invoked twice with different arguments. Should we stub them individually?
      #   allow(Cove::Steps::GetExistingContainerDetails).to receive(:call).with(kind_of(SSHKit::Backend::Abstract), anything) {
      #     Cove::Runtime::ContainerList.new([
      #       Cove::Runtime::Container.new(id: "1234", name: "legacy_container1", image: service.image, status: "running", service: service.name, role: role.name, version: "fake", index: 1),
      #       Cove::Runtime::Container.new(id: "4567", name: "legacy_container2", image: service.image, status: "running", service: service.name, role: role.name, version: "fake", index: 2)
      #     ])
      #   }

      #   stubs = []
      #   desired_container1 = Cove::DesiredContainer.from(instance1)
      #   desired_container2 = Cove::DesiredContainer.from(instance2)

      #   stubs << stub_command(/docker image pull app:latest/).with_exit_status(0)
      #   stubs << stub_command(/mkdir -p #{File.join(Cove.host_base_dir, "env", service.name, role.name)}/)
      #   stubs << stub_command(/docker container create .* #{desired_container1.name}.* --publish 8080:80/).with_exit_status(0)
      #   stubs << stub_command(/docker container create .* #{desired_container2.name}.* --publish 8081:80/).with_exit_status(0)
      #   stubs << stub_command(/docker container stop legacy_container1/).with_exit_status(0)
      #   stubs << stub_command(/docker container stop legacy_container2/).with_exit_status(0)
      #   stubs << stub_command(/docker container start #{desired_container1.name}/).with_exit_status(0)
      #   stubs << stub_command(/docker container start #{desired_container2.name}/).with_exit_status(0)
      #   stubs << stub_upload(File.join(Cove.host_base_dir, "env", service.name, role.name, "#{deployment.version}.env"))

      #   invocation = described_class.new(registry: registry, service: service)

      #   invocation.invoke

      #   stubs.each { |stub| expect(stub).to have_been_invoked }
      # end
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

    def setup_environment(service_name: "test", role_name: "web", image: "app:latest", container_count: 1, command: [], ports: [], mounts: [])
      host = Cove::Host.new(name: "1.1.1.1")
      service = Cove::Service.new(name: service_name, image: image)
      role = Cove::Role.new(name: role_name, service: service, hosts: [host], container_count: container_count, command: command, ports: ports, mounts: mounts)
      registry = Cove::Registry.build(hosts: [host], services: [service], roles: [role])

      [registry, service, role]
    end
  end
end
