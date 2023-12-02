module Cove
  class DeploymentConfig
    class ConfigFile
      attr_reader :path, :content

      def initialize(path:, content:)
        @path = path
        @content = content
      end

      def directory
        dir = File.dirname(path)
        dir unless dir == "."
      end
    end
  end
end
