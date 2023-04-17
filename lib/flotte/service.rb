module Flotte
  class Service < Struct.new(:name, :image, :environment, :roles, keyword_init: true)
    class Role < Struct.new(:name, :environment, :ingress, keyword_init: true)
    end

    def roles
      @roles ||= Flotte::Registry::Role.new
    end
  end
end
