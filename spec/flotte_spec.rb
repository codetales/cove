# frozen_string_literal: true

RSpec.describe Flotte do
  it "has a version number" do
    expect(Flotte::VERSION).not_to be nil
  end

  it "prints the version" do
    expect { Flotte::CLI::Main.new.invoke(:version) }.to output("#{Flotte::VERSION}\n").to_stdout
  end
end
