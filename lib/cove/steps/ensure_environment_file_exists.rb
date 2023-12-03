module Cove
  module Steps
    class EnsureEnvironmentFileExists
      include Callable

      # @return [SSHKit::Backend::Abstract]
      attr_reader :connection
      # @return [Cove::Package]
      attr_reader :package

      def initialize(connection, package)
        @connection, @package = connection, package
      end

      def call
        env = EnvironmentFile.new(package)
        connection.info("Ensuring environment file exists")
        connection.execute(:mkdir, "-p", env.host_directory_path, "&&", "chmod", "700", env.host_directory_path)
        connection.upload!(StringIO.new(env.content), env.host_file_path)
      end
    end
  end
end
