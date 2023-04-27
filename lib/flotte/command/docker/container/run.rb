module Flotte
  module Command
    module Docker
      module Container
        class Run
          def self.build(image:, name: nil, remove: false, detach: true, interactive: false, labels: {}, command: [], ports: [], extra_arguments: [])
            builder = [:docker, "container", "run"]

            builder += ["--name", name] if name.present?

            Array(ports).each do |port_mapping|
              builder += ["--publish", port_mapping]
            end

            Hash(labels).each do |key, value|
              builder += ["--label", "#{key}=#{value}"]
            end

            builder << "--detach" if detach
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
