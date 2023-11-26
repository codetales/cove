module Cove
  class DeploymentConfig
    class Digest
      def for(digestables)
        to_digest = digestables.sort_by do |digestable|
          [digestable.first, digestable.second]
        end.map do |digestable|
          digestable.join("")
        end.join("")

        ::Digest::SHA2.hexdigest(to_digest)
      end
    end
  end
end
