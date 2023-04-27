module Cove
  module Command
    module Docker
      module Container
        class Stop
          def self.build(id:, time: nil)
            builder = [:docker, "container", "stop", id]

            builder += ["--time", time.to_s] if time.present?

            builder
          end
        end
      end
    end
  end
end
