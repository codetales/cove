# TODO

# SSHKit

- Negative matchers
- Counts for upload stubs
- Counts for matchers
- Move to gem

## Configs

- What information do I want to render?

  - instance_number
  - secrets
  - env vars
  - defined vars from configs?
  - connect to other services

  ```ruby
  # internal stuff
  this.dockerhost # IP of the host running this service
  this.service_name
  this.role_name
  this.version

  # Single host for a service/role
  host.running("postgres/primary").ip %>

  # Hosts running reb role for mastadon
  hosts.running("mastadon/web").map { |host| host.ip }.join(", ")

  # All hosts that run any roles for mastaodon
  hosts.running("mastadon").map { |host| host.ip }.join(", ")

  # May return anything, including an array?
  vars["some.var.name.can.be.nested"]

  # returns a string?
  secrets["some.secret.name"]
  ```

* Render config files

  - What information should be accessible in the config?

* Calculate the version

  - Based on config and rendered result
  - Need to do this per persion or something?
  - Is pre-rendering suboptimal? E.g. if there are many hosts, that would take time
  - Is there a way to pass in "placeholders"

  - Versioning of
    - the "service" config including the `configs` block
    - the "config" version based on the rendered results
    - the container name needs both versions to avoid conflicts

* Upload files

## Clean up

- Remove `Command::Builder` in favor of embedding commands
- Move `Command::Docker` to `Docker::CLI`
- Rename `Invocation` to `Command`
- Make the console useful for debugging
  - I'd want to be able to connect to a host and execute steps as needed

## API changes

- cove up | cove service up
- cove down | cove service down

- cove run | cove service run | cove session start
- cove exec | cove service exec | cove service attach

- cove session list
- cove session create
- cove session start
- cove session attach
- cove session stop
- cove session rm

- cove service ps
- cove service list
- cove service hosts

- cove host list
- cove host ssh
