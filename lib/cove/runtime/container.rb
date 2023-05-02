module Cove
  module Runtime
    class Container
      include ActiveModel::API
      include ActiveModel::Attributes

      def self.build_from_config(container)
        new(
          id: container["Id"],
          name: container["Name"]&.delete("/"),
          status: container.dig("State", "Status"),
          service: container.dig("Config", "Labels", "cove.service"),
          role: container.dig("Config", "Labels", "cove.role"),
          version: container.dig("Config", "Labels", "cove.version")
        )
      end

      attribute :id, :string
      attribute :name, :string
      attribute :status, :string
      attribute :service, :string
      attribute :role, :string
      attribute :version, :string
    end
  end
end
