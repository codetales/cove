module Cove
  class RoleConfig
    # @return [String] The source of the config
    attr_reader :source
    # @return [String] Where to mount the config in the container
    attr_reader :target

    # @param [String] source The source of the config
    # @param [String] target Where to mount the config in the container
    def initialize(source:, target:)
      @source = source
      @target = target
    end
  end
end
