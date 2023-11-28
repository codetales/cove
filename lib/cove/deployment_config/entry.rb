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
        @files ||= FileResolver.new.call(registry: @registry, deployment: @deployment, source: source)
      end
    end
  end
end
