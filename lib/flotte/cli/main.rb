module Flotte
  module CLI
    class Main < Thor
      include SSHKit::DSL

      desc "version", "Print the installed version of flotte"
      def version
        puts Flotte::VERSION
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
          command = Flotte::Command::SSH.wrap(host, [:docker, :container, :attach, container_name, ';', "echo", "'42424242'"])
          info "Running #{command.join(' ')}"
          Kernel.exec *command
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
    end
  end
end
