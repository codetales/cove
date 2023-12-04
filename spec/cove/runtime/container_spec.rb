RSpec.describe Cove::Runtime::Container do
  describe ".build_from_config" do
    context "for a container with a healthcheck" do
      it "sets the container details" do
        config = {
          "Name" => "/foobar2",
          "Id" => "c354c21b4682e6c57819ec13371c3eec328810726048ce09a4d94f185ac375f4",
          "State" => {
            "Status" => "running",
            "Running" => true,
            "Paused" => false,
            "Restarting" => false,
            "OOMKilled" => false,
            "Dead" => false,
            "Pid" => 736936,
            "ExitCode" => 0,
            "Error" => "",
            "StartedAt" => "2023-07-02T02:28:14.910970609Z",
            "FinishedAt" => "0001-01-01T00:00:00Z",
            "Health" => {
              "Status" => "healthy",
              "FailingStreak" => 0, "Log" => []
            }
          },
          "Config" => {
            "Labels" => {
              "cove.version" => "58da9973e60f0",
              "cove.index" => "1",
              "cove.role" => "web",
              "cove.service" => "nginx",
              "maintainer" => "NGINX Docker Maintainers <docker-maint@nginx.com>"
            }
          }
        }

        container = described_class.build_from_config(config)

        expect(container.id).to eq("c354c21b4682e6c57819ec13371c3eec328810726048ce09a4d94f185ac375f4")
        expect(container.name).to eq("foobar2")
        expect(container.image).to eq(nil)
        expect(container.status).to eq("running")
        expect(container.service).to eq("nginx")
        expect(container.role).to eq("web")
        expect(container.version).to eq("58da9973e60f0")
        expect(container.index).to eq(1)
        expect(container.health_status).to eq("healthy")
      end

      context "for a running healthy container" do
        it "returns the right statuses" do
          config = build_container_config(status: "running", health_status: "healthy")
          container = described_class.build_from_config(config)

          expect(container.running?).to eq(true)
          expect(container.healthy?).to eq(true)
        end
      end

      context "for a running unhealthy container" do
        it "returns the right statuses" do
          config = build_container_config(status: "running", health_status: "unhealthy")
          container = described_class.build_from_config(config)

          expect(container.running?).to eq(true)
          expect(container.healthy?).to eq(false)
        end
      end

      context "for a exited unhealthy container" do
        it "returns the right statuses" do
          config = build_container_config(status: "exited", health_status: "unhealthy")
          container = described_class.build_from_config(config)

          expect(container.running?).to eq(false)
          expect(container.healthy?).to eq(false)
        end
      end

      context "for an exited container without a health check" do
        it "returns the right statuses" do
          config = build_container_config(status: "exited", health_status: nil)
          container = described_class.build_from_config(config)

          expect(container.running?).to eq(false)
          expect(container.healthy?).to eq(false)
        end
      end

      context "for a running container without a health check" do
        it "returns the right statuses" do
          config = build_container_config(status: "running", health_status: nil)
          container = described_class.build_from_config(config)

          expect(container.running?).to eq(true)
          expect(container.healthy?).to eq(true)
        end
      end
    end

    def build_container_config(name: "foobar", status: "running", health_status: nil)
      base_config = {
        "Name" => "/#{name}",
        "Id" => "c354c21b4682e6c57819ec13371c3eec328810726048ce09a4d94f185ac375f4",
        "State" => {
          "Status" => status,
          "Running" => status == "running",
          "Paused" => false,
          "Restarting" => false,
          "OOMKilled" => false,
          "Dead" => false,
          "Pid" => 736936,
          "ExitCode" => 0,
          "Error" => "",
          "StartedAt" => "2023-07-02T02:28:14.910970609Z",
          "FinishedAt" => "0001-01-01T00:00:00Z"
        },
        "Config" => {
          "Labels" => {
            "cove.version" => "58da9973e60f0",
            "cove.index" => "1",
            "cove.role" => "web",
            "cove.service" => "nginx",
            "maintainer" => "NGINX Docker Maintainers <docker-maint@nginx.com>"
          }
        }
      }

      health_config = {
        "Health" => {
          "Status" => health_status,
          "FailingStreak" => 0, "Log" => []
        }
      }

      if health_status
        base_config["State"].merge!(health_config)
      end
      base_config
    end
  end
end
