module Cove
  class EnvironmentFile
    # @return [Cove::Role]
    attr_reader :package

    def initialize(package)
      @package = package
    end

    def host_directory_path
      # TODO: Make the base path configurable
      "#{Cove.host_base_dir}/env/#{package.service_name}/#{package.role_name}"
    end

    def host_file_path
      "#{host_directory_path}/#{package.version}.env"
    end

    def content
      package.environment_variables.map do |key, value|
        "#{key}=#{value}"
      end.join("\n")
    end
  end
end
