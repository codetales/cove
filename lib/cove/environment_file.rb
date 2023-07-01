module Cove
  class EnvironmentFile
    # @return [Cove::Role]
    attr_reader :role

    def initialize(role)
      @role = role
    end

    def host_directory_path
      # TODO: Make the base path configurable
      "/var/cove/env/#{role.service.name}/#{role.name}"
    end

    def host_file_path
      "#{host_directory_path}/#{role.version}.env"
    end

    def content
      role.environment_variables.map do |key, value|
        "#{key}=#{value}"
      end.join("\n")
    end
  end
end
