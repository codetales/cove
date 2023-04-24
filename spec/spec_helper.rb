# frozen_string_literal: true

require "flotte"
require "byebug"
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
    Flotte.output = StringIO.new
    SSHKitTest::Commander.reset
  end

  config.include(SSHKitTest)
  SSHKit.config.backend = SSHKitTest::Backend
end
