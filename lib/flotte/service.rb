module Flotte
  class Service < Data.define(:name, :image, :default_environment)
    # @return [String]
    attr_reader :name, :image
    # @return [Hash]
    attr_reader :default_environment

    # @param [String] name
    # @param [String] image
    # @param [Hash] default_environment
    def initialize(name:, image:, default_environment: {})
      @name = name
      @image = image
      @default_environment = default_environment
    end

    # @return [String]
    def id
      name
    end
  end
end
