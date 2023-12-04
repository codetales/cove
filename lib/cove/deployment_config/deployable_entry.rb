module Cove
  class DeploymentConfig
    class DeployableEntry
      def initialize(host_path:, entry:)
        @base_path = File.join(host_path, entry.name)
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

      def source
        File.join(@base_path, @entry.base)
      end

      def target
        @entry.target
      end
    end
  end
end
