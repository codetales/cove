module Cove
  class EntityLabels
    include Enumerable

    delegate :each, to: :@labels

    # @param labels [Hash<String, String>]
    def initialize(labels)
      @labels = labels.to_h
    end

    # @return [Array<String>] An array of strings where each string represents a valid Docker CLI filter for a label
    def as_filters
      to_a.map { |label| "label=#{label}" }
    end

    # @return [Hash<String, String>]
    def to_h
      @labels.to_h
    end

    # @return [Array<String>] An array of strings where each string represents a valid Docker CLI label
    def to_a
      @labels.map { |key, value| "#{key}=#{value}" }
    end

    # @return [EntityLabels]
    # @param other [EntityLabels, Hash<String, String>]
    def merge(other)
      EntityLabels.new(@labels.merge(other.to_h))
    end
  end
end
