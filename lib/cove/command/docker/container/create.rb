module Cove
  module Command
    module Docker
      module Container
        class Create
          def self.build(image:, name: nil, remove: false, interactive: false, labels: {}, command: [], ports: [], mounts: [], environment_files: [], extra_arguments: [])
            builder = [:docker, "container", "create"]

            builder += ["--name", name] if name.present?

            Array(ports).each do |port_mapping|
              builder += ["--publish", port_mapping["source"].to_s + ":" + port_mapping["target"].to_s]
            end

            Array(mounts).each do |mount|
              builder += ["--mount", "type=#{mount["type"] || "volume"},source=#{mount["source"]},target=#{mount["target"]}"]
            end

            Array(labels).each do |label|
              builder += ["--label", label]
            end

            Array(environment_files).each do |environment_file|
              builder += ["--env-file", environment_file]
            end

            builder << "--rm" if remove
            builder << "-it" if interactive

            builder += Array(extra_arguments)

            builder << image
            builder += Array(command)

            builder
          end
        end
      end
    end
  end
end
