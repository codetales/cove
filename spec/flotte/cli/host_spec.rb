# frozen_string_literal: true

RSpec.describe Flotte::CLI::Host do
  describe "#version" do
    it "prints the version" do
      Flotte.init(config: "spec/fixtures/configs/basic/")
      described_class.new.invoke(:list)

      expect(Flotte.output.string).to eq(
        "host1\nhost2\nhost3\n"
      )
    end
  end
end
