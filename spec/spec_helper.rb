# frozen_string_literal: true

require "cove"
require "byebug"
require "mocktail"

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    Cove.output = StringIO.new
    SSHKit.config.output = SSHKit::Formatter::Pretty.new(Cove.output)
    SSHTestKit.reset!
  end

  config.include(SSHTestKit::StubHelpers)
  config.include(SSHTestKit::RSpecMatchers)
  SSHKit.config.backend = SSHTestKit::Backend

  config.include Mocktail::DSL
  config.after(:example) { Mocktail.reset }
end
