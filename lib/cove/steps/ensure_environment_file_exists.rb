module Cove
  module Steps
    class EnsureEnvironmentFileExists
      include Callable

      # @return [SSHKit::Backend::Abstract]
      attr_reader :connection
      # @return [Cove::Deployment]
      attr_reader :deployment

      def initialize(connection, deployment)
        @connection, @deployment = connection, deployment
      end

      def call
        env = EnvironmentFile.new(deployment)
        connection.info("Ensuring environment file exists")
        connection.execute(:mkdir, "-p", env.host_directory_path, "&&", "chmod", "700", env.host_directory_path)
        connection.upload!(StringIO.new(env.content), env.host_file_path)
      end
    end
  end
end
