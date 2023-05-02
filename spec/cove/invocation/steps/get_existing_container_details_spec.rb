RSpec.describe Cove::Invocation::Steps::GetExistingContainerDetails do
  describe ".call" do
    context "with matching containers" do
      it "returns the container details" do
        host = Cove::Host.new(name: "host1")
        service = Cove::Service.new(name: "test-service", image: "nginx:latest")
        connection = SSHKitTest::Backend.new(host.sshkit_host)

        stub_command(Cove::Command::Builder.list_containers_matching("label=cove.service=test-service"))
          .with_stdout("container1\ncontainer2\n")
        stub_command(Cove::Command::Builder.inspect_containers("container1", "container2"))
          .with_stdout(
            <<~JSON
              [
                {
                  "Id": "bfefb9ad7622b4b45465621115df5c9acd1cf97f977efaa1ae878d7f432315c4",
                  "Name": "/container1",
                  "State": {
                    "Status": "running"
                  },
                  "Config": {
                    "Labels": {
                      "cove.service": "test-service",
                      "cove.role": "web",
                      "cove.version": "1.0.0"
                    }
                  }
                },
                {
                  "Id": "636c4cd49966e3c99f9b050fe5b13921e506f6fdf74acf7a591751199db62d8d",
                  "Name": "/container2",
                  "State": {
                    "Status": "running"
                  },
                  "Config": {
                    "Labels": {
                      "cove.service": "test-service",
                      "cove.role": "web",
                      "cove.version": "1.0.0"
                    }
                  }
                }
              ]
            JSON
          )

        containers = described_class.call(connection, service)

        expect(containers.first.name).to eq("container1")
        expect(containers.last.name).to eq("container2")
      end
    end

    context "without matching containers" do
      it "returns an empty list" do
        host = Cove::Host.new(name: "host1")
        service = Cove::Service.new(name: "test-service", image: "nginx:latest")
        connection = SSHKitTest::Backend.new(host.sshkit_host)

        stub_command(Cove::Command::Builder.list_containers_matching("label=cove.service=test-service"))
          .with_stdout("\n")

        containers = described_class.call(connection, service)

        expect(containers).to be_empty
      end
    end
  end
end
