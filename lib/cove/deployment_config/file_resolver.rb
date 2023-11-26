module Cove
  class DeploymentConfig
    class FileResolver
      def call(registry:, deployment:, source:)
        path = File.join(deployment.directory, source)
        renderer = Renderer.new(registry, deployment)

        if File.directory?(path)
          Dir.glob(File.join(path, "**/*"))
        else
          [path]
        end.map do |file|
          [file.gsub(/^#{deployment.directory}/, ""), renderer.call(file)]
        end.map do |path, content|
          ConfigFile.new(path: path, content: content)
        end
      end
    end
  end
end
