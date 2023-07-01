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
        Cove.registry.roles.select { |role| role.service == service }.flat_map(&:hosts).uniq.each do |host|
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
    end
  end
end
