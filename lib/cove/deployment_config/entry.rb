module Cove
  class DeploymentConfig
    class Entry
      attr_reader :name, :target, :source

      def initialize(registry:, deployment:, name:, source:, target:)
        @registry = registry
        @deployment = deployment
        @name = name
        @source = source
        @target = target
      end

      def base
        # If the source is a file want to make sure to directly mount the file,
        # otherwise we will try to mount the root of the source as a directory.
        if File.file?(path)
          File.basename(source)
        else
          "/"
        end
      end

      def digestables
        files.map do |file|
          [name, file.path, file.content]
        end
      end

      def directories
        files.map(&:directory).compact.uniq
      end

      def files
        @files ||= resolver.call(registry: @registry, deployment: @deployment, source: source)
      end

      def resolver
        @resolver ||= FileResolver.new
      end

      private

      def path
        File.join(@deployment.directory, @source)
      end
    end
  end
end
