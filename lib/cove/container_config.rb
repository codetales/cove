module Cove
  class ContainerConfig
    include ActiveModel::API
    include ActiveModel::Attributes

    attribute :name, :string
    attribute :image, :string
    attribute :command, :string
    attribute :labels, array: true, default: -> { [] }
    attribute :environment, default: -> { {} }
    attribute :volumes, array: true, default: -> { [] }
    attribute :ports, array: true, default: -> { [] }
  end
end
