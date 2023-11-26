module Cove
  class DeploymentConfig
    class DeployableFile
      def initialize(base_path, file)
        @base_path = base_path
        @file = file
      end

      def content
        @file.content
      end

      def host_path
        File.join(@base_path, @file.path)
      end
    end
  end
end
