module SSHKitTest
  def stub_command(command)
    stub = CommandStub.new(command)
    Commander.register_command_stub(stub)
    stub
  end

  class Backend < SSHKit::Backend::Abstract
    def execute_command(cmd)
      result = Commander.result_for(host, cmd)
      cmd.on_stdout(nil, result.stdout) if result.stdout
      cmd.on_stderr(nil, result.stderr) if result.stderr
      cmd.exit_status = result.exit_status
    end
  end

  class Commander
    class << self
      def reset
        @stubs = StubRegistry.new
        @logs = CommandLog.new
      end

      def register_command_stub(stub)
        @stubs.register(stub)
      end

      def result_for(host, cmd)
        @logs.add(host, cmd)
        @stubs.find_matching(cmd, host)
      end
    end
  end

  class CommandStub
    attr_reader :command, :stdout, :stderr, :exit_status, :host

    def initialize(command)
      @command = command
      @stdout = ""
      @stderr = ""
      @exit_status = 0
      @host = nil
    end

    def on(host)
      @host = host
      self
    end

    def with_stdout(stdout)
      @stdout = stdout
      self
    end

    def with_stderr(stderr)
      @stderr = stderr
      self
    end

    def with_exit_status(exit_status)
      @exit_status = exit_status
      self
    end
  end

  class CommandLog
    def add(host, cmd)
      @log ||= Hash.new { |h, k| h[k] = [] }
      @log[host.hostname] << cmd
    end

    def get(hostname)
      @log[hostname]
    end
  end

  class StubRegistry
    def initialize
      @stubs = []
    end

    def register(stub)
      @stubs << stub
    end

    def find_matching(cmd, host)
      stub = @stubs.find do |stub|
        (stub.host.blank? || stub.host === cmd.host.hostname) &&
          stub.command === cmd.to_command
      end

      stub || CommandStub.new(nil)
    end
  end
end
