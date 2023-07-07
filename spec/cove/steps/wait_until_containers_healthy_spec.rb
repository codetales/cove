RSpec.describe Cove::Steps::WaitUntilContainersHealthy do
  let(:test_sleeper) {
    Class.new do
      def self.sleep(_)
        nil
      end
    end
  }

  describe "#call" do
    it "it retries the health check for max_attempts" do
      connection = double
      container_names = ["test_container"]
      max_attempts = 10
      wait_time = 30

      expect(Cove::Steps::CaptureContainerDetails).to receive(:call).with(connection, container_names).and_return([double(name: "foobar", healthy?: false)]).exactly(10).times

      expect {
        described_class.call(connection, container_names, max_attempts: max_attempts, wait_time: wait_time, sleeper: test_sleeper)
      }.to raise_error(described_class::HealthCheckFailed)
    end
  end
end
