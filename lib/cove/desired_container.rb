module Cove
  class DesiredContainer
    include ActiveModel::API
    include ActiveModel::Attributes

    def self.from(role, index)
      name = "#{role.service.name}-#{role.name}-#{role.version}-#{index}"
      new(
        name: name,
        image: role.image,
        command: role.command,
        labels: role.labels,
        environment: role.environment
      )
    end

    attribute :name, :string
    attribute :image, :string
    attribute :command, :string
    attribute :labels, array: true, default: -> { [] }
    attribute :environment, default: -> { {} }
    attribute :volumes, array: true, default: -> { [] }
    attribute :ports, array: true, default: -> { [] }
  end
end
