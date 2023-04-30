module Cove
  module CLI
    class Main < Thor
      include SSHKit::DSL

      def self.exit_on_failure?
        true
      end

      desc "version", "Print the installed version of Cove"
      def version
        Cove.output.puts Cove::VERSION
      end

      desc "host", "Host specific commands"
      subcommand "host", Cove::CLI::Host

      desc "service", "Service specific commands"
      subcommand "service", Cove::CLI::Service
    end
  end
end
