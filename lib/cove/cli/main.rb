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

      desc "runit", "Run a command"
      def runit
        captured = {}
        image = "alpine"
        container_name = "test-#{SecureRandom.alphanumeric(5)}"
        host = "root@test"
        on(host) do |host|
          output = capture(*Command::Docker::Container::Run.build(image: image, name: container_name, remove: false, interactive: true), {verbosity: Logger::INFO})

          captured[host] = output
        end

        run_locally do
          command = Cove::Command::SSH.wrap(host, [:docker, :container, :attach, container_name, ";", "echo", "'42424242'"])
          info "Running #{command.join(" ")}"
          Kernel.exec(*command)
        end
      end

      desc "logs", "Tail logs"
      def logs
        host = "root@test"
        on([host]) do |host|
          SSHKit.config.output_verbosity = Logger::DEBUG
          execute :docker, "logs", "-f", "goofy_meitner"
        end
      end

      desc "host", "Host specific commands"
      subcommand "host", Cove::CLI::Host

      desc "service", "Service specific commands"
      subcommand "service", Cove::CLI::Service
    end
  end
end
