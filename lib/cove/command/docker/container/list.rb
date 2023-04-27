module Cove
  module Command
    module Docker
      module Container
        class List
          # @param all [Boolean] Show all containers (default shows just running)
          # @param format [Array<String>] Pretty-print containers using a Go template
          # @param filter [String] Filter output based on conditions provided
          # @param quiet [Boolean] Only display container IDs
          # @param truncate [Boolean] Truncate output (defaults to false)
          # @return [Array<String>]
          def self.build(all: false, format: nil, filter: [], quiet: false, truncate: false)
            builder = [:docker, "container", "ls"]
            builder << "--all" if all
            builder << "--quiet" if quiet
            builder << "--no-trunc" unless truncate
            builder += ["--format", format] if format.present?
            Array(filter).each do |filter|
              builder += ["--filter", filter]
            end
            builder
          end
        end
      end
    end
  end
end
