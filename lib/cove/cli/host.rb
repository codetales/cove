module Cove
  module CLI
    class Host < Thor
      include SSHKit::DSL

      desc "list", "List hosts"
      def list
        Cove.registry.hosts.each do |host|
          Cove.output.puts host.name
        end
      end

      desc "ssh HOST", "Connect to HOST via SSH"
      def ssh(host)
        host = Cove.registry.hosts[host]
        command = ["ssh", "-t", host.ssh_destination_string]
        run_locally do
          info "Connecting to host #{host.name} via #{command.join(" ")}"
          Kernel.exec(*command)
        end
      end
    end
  end
end
