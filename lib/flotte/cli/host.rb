module Flotte
  module CLI
    class Host < Thor
      include SSHKit::DSL

      desc "list", "List hosts"
      def list
        Flotte.registry.hosts.each do |host|
          puts host.name
        end
      end

      desc "ssh HOST", "Connec to HOST via SSH"
      def ssh(host)

      end
    end
  end
end
