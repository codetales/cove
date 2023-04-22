module Flotte
  class Host < Struct.new(:name, :hostname, :user, keyword_init: true)
    def id
      name
    end

    def ssh_destination_string
      [user, hostname].compact.join("@")
    end

    def hostname
      super.presence || name
    end
  end
end
