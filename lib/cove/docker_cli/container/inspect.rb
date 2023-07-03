module Cove
  module DockerCLI
    module Container
      class Inspect
        # @param container_names [Array<String>]
        # @return [Array<String>]
        def self.build(*container_names)
          new(*container_names).to_cmd
        end

        def initialize(*container_names)
          @container_names = container_names.flatten
        end

        # @return [Array<String>]
        def to_cmd
          [:docker, "container", "inspect", *@container_names]
        end
      end
    end
  end
end
