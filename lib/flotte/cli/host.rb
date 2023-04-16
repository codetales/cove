module Flotte
  module CLI
    class Host < Thor
      include SSHKit::DSL

      desc "list", "List hosts"
      def list

      end

      desc "ssh HOST", "Connec to HOST via SSH"
      def ssh(host)

      end
    end
  end
end
