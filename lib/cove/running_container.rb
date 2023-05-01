module Cove
  class ExistingContainer
    include ActiveModel::API
    include ActiveModel::Attributes

    attribute :id, :string
    attribute :name, :string
    attribute :status, :string
    attribute :service, :string
    attribute :role, :string
    attribute :version, :string
  end
end
