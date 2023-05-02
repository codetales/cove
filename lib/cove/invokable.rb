module Cove::Invokable
  extend ActiveSupport::Concern

  class_methods do
    def invoke(...)
      new(...).invoke
    end
  end
end
