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
        say "test", "blue"
        captured = {}
        image = "hello-world"
        container_name = "test-#{SecureRandom.alphanumeric(5)}"
        on(["root@test"]) do |host|
          output = capture(*Command::Docker::Container::Run.build(image: image, name: container_name), {verbosity: Logger::INFO})

          captured[host] = output
        end

        p captured
      end
    end
  end
end
