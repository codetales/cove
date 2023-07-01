module Cove
  module Invocation
    module Steps
      class EnsureEnvironmentFileExists
        include Callable

        # @return [SSHKit::Backend::Abstract]
        attr_reader :connection
        # @return [Cove::Service]
        attr_reader :role

        def initialize(connection, role)
          @connection, @role = connection, role
        end

        def call
          env = EnvironmentFile.new(role)
          connection.info("Ensuring environment file exists")
          connection.execute(:mkdir, "-p", env.host_directory_path, "&&", "chmod", "700", env.host_directory_path)
          connection.upload!(StringIO.new(env.content), env.host_file_path)
        end
      end
    end
  end
end
