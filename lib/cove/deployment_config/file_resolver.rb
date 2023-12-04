module Cove
  class DeploymentConfig
    class FileResolver
      class FileNotFound < Cove::Error
        def initialize(path)
          super("File not found: #{path}")
        end
      end

      def call(registry:, deployment:, source:)
        raise FileNotFound.new(source) unless File.exist?(source)

        renderer = Renderer.new(registry, deployment)

        if File.directory?(source)
          Dir.glob(File.join(source, "**/*")).select do |file|
            File.file?(file)
          end.map do |file|
            [file.gsub(/^#{source}(\/)?/, ""), renderer.call(File.read(file))]
          end
        else
          [
            [File.basename(source), renderer.call(File.read(source))]
          ]
        end.map do |path, content|
          ConfigFile.new(path: path, content: content)
        end
      end
    end
  end
end
