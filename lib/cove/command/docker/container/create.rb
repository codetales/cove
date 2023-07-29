module Cove
  module Command
    module Docker
      module Container
        class Create
          def self.build(image:, index: nil, name: nil, remove: false, interactive: false, labels: {}, command: [], ports: [], volumes: [], environment_files: [], extra_arguments: [])
            builder = [:docker, "container", "create"]

            builder += ["--name", name] if name.present?

            Array(ports).each do |port_mapping|
              if port_mapping["type"] == "port"
                builder += ["--publish", port_mapping["source"].to_s + ":" + port_mapping["target"].to_s]
              end
              if port_mapping["type"] == "port_range"
                builder += ["--publish", port_mapping["source"][index - 1].to_s + ":" + port_mapping["target"].to_s]
              end
            end

            Array(volumes).each do |volume|
              builder += ["--mount", "type=volume,", "source=" + volume["source"] + ",", "target=" + volume["target"]]
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
