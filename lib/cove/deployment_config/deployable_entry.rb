module Cove
  class DeploymentConfig
    class DeployableEntry
      def initialize(version:, host_path:, entry:)
        @base_path = File.join(host_path, entry.name)
        @version = version
        @entry = entry
      end

      def host_directories
        [@base_path] + @entry.directories.map do |path|
          ::File.join(@base_path, path)
        end
      end

      def files
        @entry.files.map do |file|
          DeployableFile.new(@base_path, file)
        end
      end
    end
  end
end
