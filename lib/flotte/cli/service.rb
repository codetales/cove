module Flotte
  module CLI
    class Service < Thor
      include SSHKit::DSL

      desc "list", "List hosts"
      def list
        Flotte.registry.services.each do |service|
          Flotte.output.puts service.name
        end
      end

      desc "hosts SERVICE", "List all roles within the service"
      def hosts(service_name)
        service = Flotte.registry.services[service_name]
        Flotte.registry.roles.select { |role| role.service == service }.flat_map(&:hosts).uniq.each do |host|
          Flotte.output.puts host.name
        end
      end

      desc "up SERVICE", "Ensure SERVICE is up and running"
      def up(service_name)
        service = Flotte.registry.services[service_name]
        Flotte::Invocation::ServiceUp.new(registry: Flotte.registry, service: service).invoke
      end
    end
  end
end
