module Cove
  class EnvironmentFile
    # @return [Cove::Role]
    attr_reader :deployment

    def initialize(deployment)
      @deployment = deployment
    end

    def host_directory_path
      # TODO: Make the base path configurable
      "/var/cove/env/#{deployment.service_name}/#{deployment.role_name}"
    end

    def host_file_path
      "#{host_directory_path}/#{deployment.version}.env"
    end

    def content
      deployment.environment_variables.map do |key, value|
        "#{key}=#{value}"
      end.join("\n")
    end
  end
end
