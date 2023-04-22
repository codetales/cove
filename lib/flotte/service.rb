module Flotte
  class Service < Struct.new(:name, :image, :default_environment, keyword_init: true)
    def id
      name
    end

    def roles
      @roles ||= Flotte::Registry::Role.new
    end
  end
end
