module Cove
  module CLI
    class Service < Thor
      include SSHKit::DSL

      desc "list", "List hosts"
      def list
        Cove.registry.services.each do |service|
          Cove.output.puts service.name
        end
      end

      desc "hosts SERVICE", "List all roles within the service"
      def hosts(service_name)
        service = Cove.registry.services[service_name]
        Cove.registry.roles_for_service(service).flat_map(&:hosts).uniq.each do |host|
          Cove.output.puts host.name
        end
      end

      desc "up SERVICE", "Ensure SERVICE is up and running"
      def up(service_name)
        service = Cove.registry.services[service_name]
        Cove::Invocation::ServiceUp.new(registry: Cove.registry, service: service).invoke
      end

      desc "down SERVICE", "Stop and delete all containers for SERVICE"
      def down(service_name)
        service = Cove.registry.services[service_name]
        Cove::Invocation::ServiceDown.new(registry: Cove.registry, service: service).invoke
      end

      desc "ps SERVICE", "List all containers and their status for SERVICE"
      def ps(service_name)
        service = Cove.registry.services[service_name]
        Cove::Invocation::ServicePs.new(registry: Cove.registry, service: service).invoke
      end

      desc "logs SERVICE/ROLE", "Show logs for role within service"
      def logs(service_role)
        role = Cove.registry.roles[service_role]
        Cove::Invocation::ServiceLogs.new(registry: Cove.registry, role: role).invoke
      rescue SignalException
        # TODO: This is a hack to swallow the exception when pressing Ctrl+C
        # It closes the connection but the `docker logs` command stays running
        # on the host(s).
        Kernel.exit(0)
      end

      desc "run SERVICE with COMMANDS", "Run a container with custom commands for SERVICE"
      option :role
      option :instance
      option :host
      def runCustom(service_name, custom_command)
        service = Cove.registry.services[service_name]
        custom_cmd = custom_command.split

        role = if options[:role]
          Cove.registry.roles_for_service(service).bsearch { |x| x.name == options[:role] }
        else
          Cove.registry.roles_for_service(service).first
        end

        host = if options[:host]
          Cove.registry.hosts[options[:host]]
        else
          role.hosts.first
        end

        index = options[:instance] || 1

        Cove.output.puts "service: #{service_name}, role: #{role.name}, host: #{host.name}, instance: #{index}, commands: #{custom_command}."

        version = Digest::SHA2.hexdigest([role.id, role.image, custom_cmd, role.environment_variables, []].to_json)[0..12]
        deployment = Cove::Deployment.new(role, version: version)
        instance = Cove::Instance.new(deployment, index)
        desired_container = Cove::DesiredContainer.from(instance)
        desired_container.command = custom_cmd
        desired_container.ports = []

        ssh_cmd = ["ssh", "-t", host.ssh_destination_string]
        run_cmd = Cove::Command::Builder.run_container(desired_container)

        cmd = ssh_cmd + run_cmd

        run_locally do
          info "Connecting to host #{host.name} and running container #{desired_container.name} via #{cmd.join(" ")}"
          Kernel.exec(*cmd)
        end
      end
    end
  end
end
