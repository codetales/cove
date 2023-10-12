module Cove
  module Invocation
    class ServiceRun
      include SSHKit::DSL

      # @return [Cove::Registry]
      attr_reader :registry
      # @return [Cove::Service]
      attr_reader :service
      # @return [Array<String>]
      attr_reader :custom_cmd
      # @return [Cove::Role]
      attr_reader :role
      # @return [Cove::Host]
      attr_reader :host

      # @param registry [Cove::Registry]
      # @param service [Cove::Service]
      # @param custom_cmd [Array<String>]
      # @param role [Cove::Role]
      # @param host [Cove::Host]
      def initialize(registry:, service:, custom_cmd:, role:, host:)
        @registry = registry
        @service = service
        @custom_cmd = custom_cmd
        @role = role
        @host = host
      end

      # @return nil
      def invoke
        Cove.output.puts "service: #{service.name}, role: #{role.name}, host: #{host.name}, commands: #{custom_cmd}."
        deployment = Cove::Deployment.new(role)
        instance_on_demand = Cove::InstanceOnDemand.new(deployment, custom_cmd)
        desired_container = Cove::DesiredContainer.from(instance_on_demand)

        create_cmd = create_cmd(desired_container)
        start_cmd = start_cmd(desired_container.name)

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

      private

      # @param desired_container [Cove::DesiredContainer]
      # @return [Array<String>]
      def create_cmd(desired_container)
        Cove::Command::Builder.create_container(desired_container, remove: true, interactive: true).map(&:to_s)
      end

      # @param container_name [String]
      # @return [Array<String>]
      def start_cmd(container_name)
        (["ssh", "-t", host.ssh_destination_string] + Cove::Command::Builder.start_container_and_attach(container_name)).map(&:to_s)
      end
    end
  end
end
