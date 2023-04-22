# frozen_string_literal: true

RSpec.describe Flotte do
  describe "#version" do
    it "prints the version" do
      Flotte::CLI::Main.new.invoke(:version)
      expect(Flotte.output.string).to eq("#{Flotte::VERSION}\n")
    end
  end
end
