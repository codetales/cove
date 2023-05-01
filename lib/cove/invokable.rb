module Invokable
  include ActiveSupport::Concern

  class_methods do
    def invoke(...)
      new(...).invoke
    end
  end
end
