module SSHTestKit
  class << self
    def commander
      @commander ||= Commander.new
    end

    def reset!
      @commander = nil
    end

    def stub_command(command)
      stub = CommandStub.new(command)
      commander.register_command_stub(stub)
      stub
    end

    def stub_upload(destination)
      stub = UploadStub.new(destination)
      commander.register_upload_stub(stub)
      stub
    end

    def allow_any_command!
      commander.allow_any_command!
    end

    def allow_any_upload!
      commander.allow_any_upload!
    end
  end

  module StubHelpers
    def stub_command(command)
      SSHTestKit.stub_command(command)
    end

    def stub_upload(destination)
      SSHTestKit.stub_upload(destination)
    end

    def allow_any_command!
      SSHTestKit.allow_any_command!
    end

    def allow_any_upload!
      SSHTestKit.allow_any_upload!
    end
  end

  module RSpecMatchers
    def have_uploaded(destination)
      HaveUploadedMatcher.new(destination)
    end

    def have_executed_command(command)
      HaveExecutedCommadMatcher.new(command)
    end
  end

  module CommandHelpers
    def self.as_string(command)
      case command
      when Regexp
        "a command matching #{command.inspect}"
      when Array
        SSHKit::Command.new(*command).to_command.inspect
      else
        command.inspect
      end
    end

    def self.matching?(actual_command, potentially_matching_command)
      case potentially_matching_command
      when Regexp
        potentially_matching_command === actual_command.to_command
      when Array
        SSHKit::Command.new(*potentially_matching_command).to_command == actual_command.to_command
      else
        potentially_matching_command == actual_command.to_command
      end
    end
  end

  class Backend < SSHKit::Backend::Abstract
    def initialize(*args)
      @semaphore = Mutex.new
      super
    end

    def execute_command(command)
      @semaphore.synchronize do
        result = SSHTestKit.commander.execute_command(host, command)
        command.on_stdout(nil, result.stdout) if result.stdout
        command.on_stderr(nil, result.stderr) if result.stderr
        command.exit_status = result.exit_status
      end
    end

    def upload!(file, destination, _options = {})
      # TODO: Allow testing for options
      SSHTestKit.commander.upload!(host, file, destination)
      nil
    end
  end

  class Commander
    attr_reader :uploads, :commands

    def initialize
      @command_stubs = []
      @upload_stubs = []
      @uploads = []
      @commands = []
    end

    def register_command_stub(stub)
      @command_stubs << stub
    end

    def register_upload_stub(stub)
      @upload_stubs << stub
    end

    def allow_any_command!
      @allow_any_command = true
      default_command_stub
    end

    def allow_any_upload!
      @allow_any_upload = true
      default_upload_stub
    end

    def default_command_stub
      @default_command_stub ||= CommandStub.new(nil)
    end

    def default_upload_stub
      @default_upload_stub ||= UploadStub.new(nil)
    end

    def execute_command(host, command)
      commands << ExecutedCommand.new(host, command)

      stub = find_applicable_command_stub(command, host)
      stub.track_invokation!(host, command)
      stub
    end

    def upload!(host, file, destination)
      uploads << Upload.new(host, file, destination)

      stub = find_applicable_upload_stub(destination, host)
      stub.track_invokation!(host, file, destination)
      stub
    end

    private

    def find_applicable_command_stub(command, host)
      stub = @command_stubs.find do |stub|
        stub.applicable?(host, command)
      end

      return stub unless stub.nil?

      if @allow_any_command
        default_command_stub
      else
        raise("No stub found for #{command.to_command} on #{host}.\n\nRegistered stubs:\n#{formated_registered_command_stubs_list}\n ")
      end
    end

    def formated_registered_command_stubs_list
      @command_stubs.map(&:to_s).join("\n")
    end

    def find_applicable_upload_stub(destination, host)
      stub = @upload_stubs.find do |stub|
        stub.applicable?(host, destination)
      end

      return stub unless stub.nil?

      if @allow_any_upload
        default_upload_stub
      else
        raise("No stub found for upload to #{destination} on #{host}.\n\nRegistered stubs:\n#{registered_stubs_list}\n ")
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

    def once
      @times = 1
      self
    end

    def twice
      @times = 2
      self
    end

    def exactly(times)
      @times = times
      self
    end

    def times
      self
    end

    def applicable?(host, command)
      matches_host?(host) &&
        matches_command?(command) &&
        number_of_invocations_not_exceeded?
    end

    def track_invokation!(host, command)
      invocations << [host, command]
    end

    def invoked?
      number_of_invocations > 0
    end

    alias_method :has_been_invoked?, :invoked?

    def number_of_invocations
      invocations.size
    end

    def to_s
      command_with_host_and_times_string
    end

    private

    def matches_host?(host)
      self.host.nil? || self.host === host.hostname
    end

    def matches_command?(command)
      CommandHelpers.matching?(command, self.command)
    end

    def number_of_invocations_not_exceeded?
      @times.nil? || number_of_invocations < @times.to_i
    end

    def command_with_host_and_times_string
      base = command_with_host_string
      if @times
        base + " (executed #{number_of_invocations} of #{@times} times)"
      else
        base
      end
    end

    def command_with_host_string
      base = CommandHelpers.as_string(command)
      if host
        base + " on #{host}"
      else
        base
      end
    end
  end

  class ExecutedCommand
    def initialize(host, command)
      @host = host
      @command = command
    end

    def matches?(host, command)
      matches_host?(host) && matches_command?(command)
    end

    def to_s
      "Executed command #{CommandHelpers.as_string(command)} on #{host}"
    end

    private

    def matches_host?(host)
      host.nil? || host === @host.hostname
    end

    def matches_command?(command)
      CommandHelpers.matching?(@command, command)
    end
  end

  class UploadStub
    attr_reader :host, :invocations, :destination

    def initialize(destination)
      @host = nil
      @destination = destination
      @invocations = []
    end

    def on(host)
      @host = host
      self
    end

    def track_invokation!(host, file, destination)
      invocations << [host, file, destination]
    end

    def applicable?(host, destination)
      matches_host?(host) && matches_destination?(destination)
    end

    def invoked?
      if @for_content
        invocations.any? { |_, file, destination| file.rewind && file.read == @for_content }
      else
        number_of_invocations > 0
      end
    end

    alias_method :has_been_invoked?, :invoked?

    def number_of_invocations
      invocations.size
    end

    def to_s
      upload_with_host_string
    end

    private

    def matches_host?(host)
      self.host.nil? || self.host === host.hostname
    end

    def matches_destination?(destination)
      self.destination === destination
    end

    def upload_with_host_string
      if host
        "#{upload_string} on #{host}"
      else
        upload_string
      end
    end

    def upload_string
      base = case destination
      when Regexp
        "matching #{destination.inspect}"
      else
        destination.inspect
      end
      "Upload to #{base}"
    end
  end

  class Upload
    def initialize(host, file, destination)
      @host = host
      @file = file
      @destination = destination
    end

    def matches?(host, destination, content)
      matches_host?(host) && matches_destination?(destination) && matches_content?(content)
    end

    def to_s
      "Upload to #{@destination} on #{@host} with content #{read.to_s[0, 50].inspect}"
    end

    private

    def matches_host?(host)
      host.nil? || host === @host.hostname
    end

    def matches_destination?(destination)
      destination.nil? || @destination === destination
    end

    def matches_content?(content)
      content.nil? || content === read
    end

    def read
      @file.rewind
      @file.read
    end
  end

  class HaveUploadedMatcher
    def initialize(destination = nil, on: nil, with: nil)
      @destination = destination
      @host = on
      @with = with
    end

    def to(destination)
      @destination = destination
      self
    end

    def on(host)
      @host = host
      self
    end

    def with_content(content)
      @content = content
      self
    end

    def matches?(receiver)
      verify_receiver(receiver) && verify_expectation
    end

    attr_reader :failure_message

    private

    def verify_receiver(receiver)
      correct_receiver = receiver == SSHKit || receiver == SSHTestKit

      unless correct_receiver
        @failure_message = "Invalid receiver #{receiver.inspect} for have_uploaded.\n   Use `expect(SSHKit).to have_uploaded(...)` instead"
      end

      correct_receiver
    end

    def verify_expectation
      any_matches = SSHTestKit.commander.uploads.any? do |upload|
        upload.matches?(@host, @destination, @content)
      end

      set_failure_message unless any_matches
      any_matches
    end

    def set_failure_message
      message = "Expected to have uploaded #{@destination}"
      unless @content.nil?
        message += " containing #{@content.inspect}"
      end
      unless @host.nil?
        message += " on #{@host}"
      end

      @failure_message = message + " but it was not uploaded"
    end
  end

  class HaveExecutedCommadMatcher
    def initialize(command, on: nil)
      @command = command
      @host = on
    end

    def on(host)
      @host = host
      self
    end

    def matches?(receiver)
      verify_receiver(receiver) && verify_expectation
    end

    attr_reader :failure_message

    private

    def verify_receiver(receiver)
      correct_receiver = receiver == SSHKit || receiver == SSHTestKit

      unless correct_receiver
        @failure_message = "Invalid receiver #{receiver.inspect} for `have_executed_command`.\n   Use `expect(SSHKit).to have_executed_command(...)` instead"
      end

      correct_receiver
    end

    def verify_expectation
      any_matches = SSHTestKit.commander.commands.any? do |command|
        command.matches?(@host, @command)
      end

      set_failure_message unless any_matches
      any_matches
    end

    def set_failure_message
      string = "Expected #{CommandHelpers.as_string(@command)} to have been executed"
      unless @host.nil?
        string += " on #{@host}"
      end
      string + " but it was not"
    end
  end
end
