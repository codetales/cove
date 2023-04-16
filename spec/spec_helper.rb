# frozen_string_literal: true

require "flotte"
require "byebug"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def capture_stdout
    begin
      original_stdout = $stdout
      $stdout = StringIO.new
      yield
      byebug
      result = $stdout.read
    ensure
      $stdout = STDOUT
    end

    byebug

    result
  end
end
