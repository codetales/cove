require "dry-validation"

module Cove
  module Configuration
    module Contracts
      class ServiceContract < Dry::Validation::Contract
        params do
          required(:service_name).filled(:string)
          required(:image).filled(:string)
          required(:roles).value(:array, min_size?: 1).each do
            hash do
              required(:name).filled(:string)
              optional(:container_count).filled(:integer)
              optional(:ingress).value(:array).each do
                hash do
                  required(:type).value(included_in?: ["port", "port_range"])
                  required(:source).value(:filled?)
                  required(:target).filled(:integer)
                end
              end
            end
          end
        end

        rule(:roles).each do
          if value[:ingress].present?
            value[:ingress].each_with_index do |port, ingress_index|
              if port[:type].eql?("port")
                key(key.path.keys + [:ingress, ingress_index, :source]).failure("must be an integer") unless port[:source].is_a?(::Integer)
              elsif port[:type].eql?("port_range")
                key(key.path.keys + [:ingress, ingress_index, :source]).failure("must be an array of integers") unless port[:source].is_a?(::Array)
                if port[:source].is_a?(::Array)
                  key(key.path.keys + [:ingress, ingress_index, :source]).failure("size of source array must be greater than or equal to the container count") if value[:container_count].present? && port[:source].size < value[:container_count]
                  port[:source].each_with_index do |source, index|
                    key(key.path.keys + [:ingress, ingress_index, :source]).failure("element #{index} in the array must be an integer") unless source.is_a?(::Integer)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
