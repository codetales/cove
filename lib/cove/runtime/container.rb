module Cove
  module Runtime
    class Container
      include ActiveModel::API
      include ActiveModel::Attributes

      def self.build_from_config(container)
        new(
          id: container["Id"],
          name: container["Name"]&.delete("/"),
          image: container.dig("Config", "Image"),
          status: container.dig("State", "Status"),
          service: container.dig("Config", "Labels", "cove.service"),
          role: container.dig("Config", "Labels", "cove.role"),
          version: container.dig("Config", "Labels", "cove.version"),
          role_version: container.dig("Config", "Labels", "cove.role_version"),
          config_version: container.dig("Config", "Labels", "cove.config_version"),
          index: container.dig("Config", "Labels", "cove.index"),
          health_status: container.dig("State", "Health", "Status")
        )
      end

      attribute :id, :string
      attribute :name, :string
      attribute :image, :string
      attribute :status, :string
      attribute :service, :string
      attribute :role, :string
      attribute :version, :string
      attribute :role_version, :string
      attribute :config_version, :string
      attribute :index, :integer
      attribute :health_status, :string

      def healthy?
        if health_status.present?
          health_status == "healthy"
        else
          running?
        end
      end

      def running?
        status == "running"
      end

      def inspect
        "Container #{id} #{name}> (#{status})"
      end
    end
  end
end
