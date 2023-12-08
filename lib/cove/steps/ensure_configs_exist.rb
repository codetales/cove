module Cove
  module Steps
    class EnsureConfigsExist
      include Callable

      attr_reader :connection, :deployment_config

      def initialize(connection, deployment_config)
        @connection = connection
        @deployment_config = deployment_config
      end

      def call
        connection.info("Building and uploading configs")

        # Creating the base directory with permissive permissions
        # so that we can create the subdirectories
        connection.execute(:mkdir, "-p", deployment_config.base_directory, "&&", "chmod", "700", deployment_config.base_directory)

        # Creating all directories for the configs
        deployment_config.host_directories.each do |dir|
          connection.execute(:mkdir, "-p", dir, "&&", "chmod", "777", dir)
        end

        # TODO: We don't want to upload the files if they already exist
        deployment_config.files.each do |file|
          connection.upload!(StringIO.new(file.content), file.host_path, mode: 0o755)
        end
      end
    end
  end
end
