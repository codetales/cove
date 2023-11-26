module Cove
  class DeploymentConfig
    class ConfigFile
      attr_reader :path, :content

      def initialize(path:, content:)
        @path = path
        @content = content
      end
    end
  end
end
