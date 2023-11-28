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
    end
  end
end
