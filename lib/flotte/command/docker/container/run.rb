module Flotte
  module Command
    module Docker
      module Container
        class Run
          def self.build(image:, name: nil, command: [], ports: [], extra_arguments: [])
            built = [:docker, "container", "run"]

            built += ["--name", name] if name.present?

            Array(ports).each do |port_mapping|
              built += ["--publish", port_mapping]
            end

            built += Array(extra_arguments)

            built << image
            built += Array(command)

            built
          end
        end
      end
    end
  end
end
