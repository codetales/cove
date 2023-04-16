module Flotte
  module Command
    class SSH
      def self.wrap(host, command)
        ["ssh", "-t", host] << Array(command).map(&:to_s).join(" ")
      end
    end
  end
end
