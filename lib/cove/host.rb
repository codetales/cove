module Cove
  class Host
    # @return [String]
    attr_reader :name
    # @return [String]
    attr_reader :user
    # @return [String]
    attr_reader :sshkit_host

    # @param [String] name
    # @param [String] hostname
    # @param [String] user
    def initialize(name:, hostname: nil, user: nil)
      @name = name
      @hostname = hostname
      @user = user
      @sshkit_host ||= SSHKit::Host.new(ssh_destination_string)
    end

    # @return [String]
    def id
      name
    end

    # @return [String]
    def ssh_destination_string
      [user, hostname].compact.join("@")
    end

    # @return [String]
    def hostname
      @hostname || name
    end
  end
end
