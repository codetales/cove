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
        labels: role.labels.merge("cove.index" => index), # TODO: We would need to pull the index into the labels. Probalby best to move labels out of the role and into this class.
        environment_files: [EnvironmentFile.new(role).host_file_path],
        version: role.version,
        index: index
      )
    end

    attribute :name, :string
    attribute :image, :string
    attribute :environment_files, array: true, default: -> { [] }
    attribute :command, array: true, default: -> { [] }
    attribute :index, :integer
    attribute :version, :string
    attribute :labels, array: true, default: -> { [] }
    attribute :volumes, array: true, default: -> { [] }
    attribute :ports, array: true, default: -> { [] }
  end
end
