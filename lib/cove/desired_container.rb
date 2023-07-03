module Cove
  class DesiredContainer
    include ActiveModel::API
    include ActiveModel::Attributes

    def self.from(instance)
      name = "#{instance.service_name}-#{instance.role_name}-#{instance.version}-#{instance.index}"
      new(
        name: name,
        image: instance.image,
        command: instance.command,
        labels: instance.labels,
        environment_files: [EnvironmentFile.new(instance).host_file_path],
        version: instance.version,
        index: instance.index
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
