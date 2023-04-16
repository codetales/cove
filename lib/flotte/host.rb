module Flotte
  class Host < Struct.new(:name, :connect_via, :user, keyword_init: true)
    def connect_via
      super.presence || name
    end
  end
end
