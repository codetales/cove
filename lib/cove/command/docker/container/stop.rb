module Cove
  module Command
    module Docker
      module Container
        class Stop
          def self.build(containers, time: nil)
            builder = [:docker, "container", "stop"]

            builder += ["--time", time.to_s] if time.present?

            builder + Array(containers)
          end
        end
      end
    end
  end
end
