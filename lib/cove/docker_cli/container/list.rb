module Cove
  module DockerCLI
    module Container
      class List
        # @param filters [Array<String>]
        # @return [Array<String>]
        def self.names_matching(*filters)
          new(all: true, format: "{{.Names}}", filters: filters.flatten).to_cmd
        end

        # @param all [Boolean] Show all containers if set to true (default is false)
        # @param format [String] Pretty-print containers using a Go template
        # @param filters [Array<String>] Filter output based on conditions provided
        # @param quiet [Boolean] Only display container IDs if set to true (defaults to false)
        # @param truncate [Boolean] Truncate output if set to true (defaults to false)
        # @return [Array<String>]
        def initialize(all: false, format: nil, filters: [], quiet: false, truncate: false)
          @all = all
          @format = format
          @filters = filters
          @quiet = quiet
          @truncate = truncate
        end

        # @return [Array<String>]
        def to_cmd
          base + settings + format + filters
        end

        private

        def base
          [:docker, "container", "ls"]
        end

        def settings
          builder = []
          builder << "--all" if @all
          builder << "--quiet" if @quiet
          builder << "--no-trunc" unless @truncate
        end

        def format
          format = ["--format", format] if format.present?
          Array(format)
        end

        def filters
          Array(@filters).map do |filter|
            ["--filter", filter]
          end
        end
      end
    end
  end
end
