module Cove
  class DeploymentConfig
    class FileResolver
      class FileNotFound < Cove::Error
        def initialize(path)
          super("File not found: #{path}")
        end
      end

      def call(registry:, deployment:, source:)
        path = File.join(deployment.directory, source)
        renderer = Renderer.new(registry, deployment)

        raise FileNotFound.new(path) unless File.exist?(path)

        if File.directory?(path)
          Dir.glob(File.join(path, "**/*")).select do |file|
            File.file?(file)
          end.map do |file|
            [file.gsub(/^#{path}\//, ""), renderer.call(File.read(file))]
          end
        else
          [
            [File.basename(path), renderer.call(File.read(path))]
          ]
        end.map do |path, content|
          ConfigFile.new(path: path, content: content)
        end
      end
    end
  end
end
