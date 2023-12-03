module Cove
  class Instance
    # @return [Cove::Package]
    attr_reader :package
    # @return [Integer]
    attr_reader :index
    # @return [Cove::Role]
    delegate :role, to: :package
    # @return [Cove::Service]
    delegate :service, to: :role
    # @return [String] The version of the package
    delegate :version, to: :package
    # @return [String] The command to run in the container
    delegate :command, to: :role
    # @return [String] The image of the container
    delegate :image, to: :role

    # @param package [Cove::package] The package the container is part of
    # @param index [Integer] The index of the container in the package
    def initialize(package, index)
      @package = package
      @index = index
    end

    def name
      "#{service.name}-#{role.name}-#{version}-#{index}"
    end

    # @return [Cove::EntityLabels] The labels of the container
    def labels
      package.labels.merge({
        "cove.index" => index.to_s
      })
    end

    # @return [Array<Hash>] The volumes to mount to the container
    def mounts
      Array(role.mounts) + package.deployment_config.entries.map do |entry|
        {"source" => entry.source, "target" => entry.target, "type" => "bind"}
      end
    end

    # @return [Array<Hash>] The port mapping to run in the container
    def ports
      @ports ||= role.ports.map { |port|
        if port["type"] == "port"
          {"source" => port["source"], "target" => port["target"]}
        elsif port["type"] == "port_range"
          {"source" => port["source"][index - 1], "target" => port["target"]}
        end
      }
    end
  end
end
