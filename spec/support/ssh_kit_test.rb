module SSHKitTest
  def stub_command(command)
    stub = CommandStub.new(command)
    Commander.register_stub(stub)
    stub
  end

  def have_been_invoked(count: nil)
    RSpecSSHKitCommandInvocationMatcher.new(count: count)
  end

  class Backend < SSHKit::Backend::Abstract
    def initialize(*args)
      @semaphore = Mutex.new
      super
    end

    def execute_command(cmd)
      @semaphore.synchronize do
        result = Commander.result_for(host, cmd)
        cmd.on_stdout(nil, result.stdout) if result.stdout
        cmd.on_stderr(nil, result.stderr) if result.stderr
        cmd.exit_status = result.exit_status
      end
    end
  end

  class Commander
    class << self
      def reset
        @stubs = StubRegistry.new
        @logs = CommandLog.new
      end

      def register_stub(stub)
        @stubs.register(stub)
      end

      def result_for(host, cmd)
        @logs.add(host, cmd)
        stub = @stubs.find_matching(cmd, host)
        stub.track_invokation!(host, cmd)
        stub
      end
    end
  end

  class CommandStub
    attr_reader :command, :stdout, :stderr, :exit_status, :host, :invocations

    def initialize(command)
      @command = command
      @stdout = ""
      @stderr = ""
      @exit_status = 0
      @host = nil
      @invocations = []
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

    def track_invokation!(host, cmd)
      invocations << [host, cmd]
    end

    def invoked?
      number_of_invocations > 0
    end

    def number_of_invocations
      invocations.size
    end

    def to_s
      command_with_host_string
    end

    private

    def command_with_host_string
      if host
        "#{command_string} on #{host}"
      else
        command_string
      end
    end

    def command_string
      case command
      when Regexp
        "a command matching #{command.inspect}"
      when Array
        SSHKit::Command.new(command).to_command.inspect
      else
        command.inspect
      end
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
        (stub.host.blank? || stub.host === host.hostname) &&
          matches_command?(stub, cmd)
      end

      stub || CommandStub.new(nil)
    end

    private

    def matches_command?(stub, cmd)
      case stub.command
      when Regexp
        stub.command === cmd.to_command
      when Array
        SSHKit::Command.new(stub.command).to_command == cmd.to_command
      else
        stub.command == cmd.to_command
      end
    end
  end
end

class RSpecSSHKitCommandInvocationMatcher
  include ::RSpec::Matchers::Composable

  def initialize(count: nil)
    @count = count
  end

  def matches?(stub)
    @stub = stub

    if @count
      number_of_invocations == @count
    else
      number_of_invocations > 0
    end
  end

  def description
    "invoke #{@stub}"
  end

  def failure_message
    "expected #{@stub} to be invoked #{@count ? "#{@count} times" : "at least once"}#{(number_of_invocations > 0) ? " but it was invoked #{number_of_invocations} times" : ""}"
  end

  def failure_message_when_negated
    "expected #{@stub} not to be invoked but it was invoked #{number_of_invocations} times"
  end

  private

  def number_of_invocations
    @stub.number_of_invocations
  end
end
