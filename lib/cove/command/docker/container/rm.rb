module Cove
  module Command
    module Docker
      module Container
        class Rm
          def self.build(containers)
            [:docker, "container", "rm"] + Array(containers)
          end
        end
      end
    end
  end
end
