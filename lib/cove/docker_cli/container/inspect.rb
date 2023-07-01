module Cove
  module DockerCLI
    module Container
      class Inspect
        FORMATS = {
          health: "'{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}'",
          name_with_health: "'{{.Name}}\t{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}'"
        }.freeze

        # @param filters [Array<String>]
        # @return [Array<String>]
        def self.build(*container_names, format: nil)
          new(*container_names, format: format).to_cmd
        end

        def initialize(*container_names, format: nil)
          @container_names = container_names.flatten
          @format = format
        end

        # @return [Array<String>]
        def to_cmd
          [:docker, "container", "inspect", *format, *@container_names]
        end

        private

        def format
          format = case @format
          when Symbol
            FORMATS[@format]
          else
            @format
          end
          args = ["--format", format] if format.present?
          Array(args)
        end
      end
    end
  end
end
