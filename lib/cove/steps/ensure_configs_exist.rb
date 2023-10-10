module Cove
  module Steps
    class EnsureConfigsExist
      include Callable

      # @return [SSHKit::Backend::Abstract]
      attr_reader :connection

      # @param connection [SSHKit::Backend::Abstract]
      def initialize(connection, deployment_config)
        @connection, @deployment_config = connection, deployment_config
      end

      def call
        connection.info("Building and uploading configs")

        entries.each do |entry|
          connection.execute(:mkdir, "-p", entry.host_path, "&&", "chmod", "700", entry.host_path)
          entry.files.each do |file|
            connection.upload!(StringIO.new(file.content), file.host_path)
          end
        end
      end

      private

      def entries
        @deployment_config.entries
      end
    end
  end
end
