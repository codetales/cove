RSpec.describe Cove::Invocation::ServiceRun do
  describe "#invoke" do
    it "should create and start a container with a custom command" do
      custom_cmd = ["echo", "hello"]
      registry, service, role, host = setup_environment(service_name: "test", role_name: "web", image: "app:latest", command: ["ping", "8.8.8.8"], ports: [{"type" => "port", "source" => 8080, "target" => 80}], mounts: [{"type" => "volume", "source" => "my-volume", "target" => "/data"}])
      deployment = Cove::Deployment.new(role)
      instance_on_demand = Cove::OnDemandInstance.new(deployment, custom_cmd)
      allow(SecureRandom).to receive(:hex).with(3).and_return("abc123")

      stubs = []
      desired_container = Cove::DesiredContainer.from(instance_on_demand)

      stubs << stub_command(/docker image pull app:latest/).with_exit_status(0)
      stubs << stub_command(/mkdir -p \/var\/cove\/env\/#{service.name}\/#{role.name}/)
      stubs << stub_command(/.* docker container create .* #{desired_container.name}.* --mount type=volume,source=my-volume,target=\/data .* --rm -it .* echo hello/).with_exit_status(0)
      stubs << stub_upload("/var/cove/env/#{service.name}/#{role.name}/#{deployment.version}.env")

      expect(Kernel).to receive(:exec).with("ssh", "-t", "1.1.1.1", "docker", "container", "start", "--attach", "-i", "#{desired_container.name}")

      invocation = described_class.new(registry: registry, service: service, custom_cmd: custom_cmd, role: role, host: host)

      invocation.invoke

      stubs.each { |stub| expect(stub).to have_been_invoked }
    end

    def setup_environment(service_name: "test", role_name: "web", image: "app:latest", container_count: 1, command: [], ports: [], mounts: [])
      host = Cove::Host.new(name: "1.1.1.1")
      service = Cove::Service.new(name: service_name, image: image)
      role = Cove::Role.new(name: role_name, service: service, hosts: [host], container_count: container_count, command: command, ports: ports, mounts: mounts)
      registry = Cove::Registry.build(hosts: [host], services: [service], roles: [role])

      [registry, service, role, host]
    end
  end
end
