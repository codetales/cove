module Flotte
  class Role < Struct.new(:name, :environment, :ingress, :service, :hosts, keyword_init: true)
    delegate :image, to: :service

    def id
      "#{service.name}.#{name}"
    end
  end
end
