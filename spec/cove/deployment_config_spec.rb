require "cove/deployment_config"

RSpec.describe Cove::DeploymentConfig do
  describe "#render" do
    it "renders the config" do
      host1 = Cove::Host.new(name: "host1", hostname: "192.168.1.1")
      host2 = Cove::Host.new(name: "host2", hostname: "192.168.1.2")

      service1 = Cove::Service.new(name: "postgres", image: "postgres:latest")
      service2 = Cove::Service.new(name: "app", image: "app:latest")

      role1 = Cove::Role.new(name: "primary", service: service1, hosts: ["host1"])
      role2 = Cove::Role.new(name: "web", service: service2, hosts: ["host1"])
      role3 = Cove::Role.new(name: "worker", service: service2, hosts: ["host2"])

      deployment = Cove::Deployment.new(role1, version: "abc")

      registry = Cove::Registry.build(hosts: [host1, host2], services: [service1, service2], roles: [role1, role2, role3])

      erb = <<~ERB
        <%= "Hello" %>
        version: <%= deployment.version %>
        service: <%= deployment.service_name %>
        role: <%= deployment.role_name %>
        <%= host_running("postgres/primary").hostname %>
        <%- hosts_running("app").each do |host| -%>
        <%= host.name %>|<%= host.hostname %>
        <%- end -%>
      ERB
      expected_output = <<~OUTPUT
        Hello
        version: abc
        service: postgres
        role: primary
        192.168.1.1
        host1|192.168.1.1
        host2|192.168.1.2
      OUTPUT

      output = described_class.new(registry, deployment).render(erb)

      expect(output).to eq(expected_output)
    end
  end
end
