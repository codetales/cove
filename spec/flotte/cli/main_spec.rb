# frozen_string_literal: true

RSpec.describe Flotte do
  describe "#version" do
    it "prints the version" do
      expect { Flotte::CLI::Main.new.invoke(:version) }.to output("#{Flotte::VERSION}\n").to_stdout
    end
  end
end
