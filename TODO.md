# TODO

- If the container count changes, it is mixing up stopping with replacing
- Remove `Command::Builder` in favor of embedding commands
- Move `Command::Docker` to `Docker::CLI`
- Rename `Invocation` to `Command`
- Add tests for the DockerCLI classes
- Is there something like `hosts_for_roles(roles)` needed?
- Make the console useful for debugging
  - I'd want to be able to connect to a host and execute steps as needed
