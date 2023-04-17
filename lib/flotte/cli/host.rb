module Flotte
  module CLI
    class Host < Thor
      include SSHKit::DSL

      desc "list", "List hosts"
      def list
        Flotte.registry.hosts.each do |host|
          Flotte.output.puts host.name
        end
      end

      desc "ssh HOST", "Connec to HOST via SSH"
      def ssh(host)
        host = Flotte.registry.hosts[host]
        command = ["ssh", "-t", host.ssh_destination_string]
        run_locally do
          info "Connecting to host #{host.name} via #{command.join(" ")}"
          Kernel.exec(*command)
        end
      end
    end
  end
end
