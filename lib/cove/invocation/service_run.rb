module Cove
  module Invocation
    class ServiceRun
      include SSHKit::DSL

      # @return [Cove::Registry]
      attr_reader :registry
      # @return [Cove::Service]
      attr_reader :service
      attr_reader :custom_cmd
      attr_reader :role
      attr_reader :host

      # @param registry [Cove::Registry]
      # @param service [Cove::Service]
      # @param custom_cmd [Array<String>]
      # @param role [Cove::Role]
      # @param host [Cove::Host]
      def initialize(registry:, service:, custom_cmd:, role:, host:)
        @service = service
        @registry = registry
        @custom_cmd = custom_cmd
        @role = role
        @host = host
      end

      # @return nil
      def invoke
        Cove.output.puts "service: #{service.name}, role: #{role.name}, host: #{host.name}, commands: #{custom_cmd}."
        deployment = Cove::Deployment.new(role)
        instance_on_demand = Cove::InstanceOnDemand.new(deployment, custom_cmd)
        desired_container = Cove::DesiredContainer.new(
          name: instance_on_demand.name,
          image: instance_on_demand.image,
          command: instance_on_demand.command,
          labels: instance_on_demand.labels,
          environment_files: [EnvironmentFile.new(instance_on_demand.deployment).host_file_path],
          version: instance_on_demand.version,
          ports: instance_on_demand.ports,
          mounts: instance_on_demand.mounts
        )
        ssh_cmd = ["ssh", "-t", host.ssh_destination_string]
        create_cmd = Cove::Command::Builder.create_container(desired_container, remove: true, interactive: true)
        start_cmd = Cove::Command::Builder.start_attached_container(desired_container.name)
        create_cmd = create_cmd.map { |el| el.to_s }
        start_cmd = ssh_cmd + start_cmd
        start_cmd = start_cmd.map { |el| el.to_s }

        on(host.sshkit_host) do
          Steps::EnsureEnvironmentFileExists.call(self, deployment)
          Steps::PullImage.call(self, deployment)
          info "Creating container #{desired_container.name}"
          execute(*create_cmd)
        end

        run_locally do
          info "Starting container #{desired_container.name}"
          Kernel.exec(*start_cmd)
        end
      end
    end
  end
end
