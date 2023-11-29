module Cove
  module ConsoleHelpers
    class ConnectionWrapper
      include SSHKit::DSL

      def initialize(host, block)
        @host = host
        @block = block
      end

      def call
        block = @block
        result = nil

        on(@host) do |connection|
          result = block.call(self)
        end

        result
      end
    end

    def with_connection(host, &block)
      ConnectionWrapper.new(ssh_host(host), block).call
    end

    def reload!
      $zeitwerk_loader.reload
    end

    def ssh_host(name)
      hosts[name].sshkit_host
    end

    def hosts
      registry.hosts
    end

    def services
      registry.services
    end

    def roles
      registry.roles
    end

    def registry
      Cove.registry
    end
  end
end
