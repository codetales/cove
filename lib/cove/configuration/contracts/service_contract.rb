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
              optional(:container_count).maybe(:integer)
              optional(:ingress).value(:array).each do
                hash do
                  required(:type).filled(:string)
                  required(:source) { filled? & (int? | array?) }
                  required(:target).filled(:integer)
                end
              end
            end
          end
        end

        rule(:roles).each do
          if value[:ingress].present?
            value[:ingress].each do |port|
              key(key.path.keys + [:ingress, :type]).failure("must be port or port range") unless port[:type].eql?("port") | port[:type].eql?("port_range")
            end
          end
        end
      end
    end
  end
end
