module Cove
  class DeploymentConfig
    def self.prepare(registry, deployment)
      entries = deployment.configs.map do |name, definition|
        # TODO: Make sure we always symbolize keys when parsing the config
        definition = definition.with_indifferent_access
        Entry.new(
          registry: registry, deployment: deployment,
          name: name, source: definition[:source],
          target: definition[:target]
        )
      end

      config_digest = Digest.new
      version = config_digest.for(entries.flat_map(&:digestables))

      new(deployment: deployment, version: version, entries: entries)
    end

    def initialize(deployment:, entries:, version:)
      @entries = entries
      @deployment = deployment
      @version = version
      @service_path = ::File.join(Cove.host_base_dir, "configs", deployment.service_name)
      @host_path = ::File.join(@service_path, version)
    end

    # TODO: Is `remote_directories` and `remote_files` more applicable?
    def host_directories
      [@service_path, @host_path] + entries.flat_map(&:host_directories)
    end

    def files
      entries.flat_map(&:files)
    end

    def entries
      @entries.map do |entry|
        DeployableEntry.new(version: @version, host_path: @host_path, entry: entry)
      end
    end
  end
end
