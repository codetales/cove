# frozen_string_literal: true

RSpec.describe Cove do
  describe "#version" do
    it "prints the version" do
      Cove::CLI::Main.new.invoke(:version)
      expect(Cove.output.string).to eq("#{Cove::VERSION}\n")
    end
  end
end
