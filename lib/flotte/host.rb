module Flotte
  class Host < Struct.new(:name, :hostname, :user, keyword_init: true)
    def hostname
      super.presence || name
    end
  end
end
