# TODO

## DeploymentConfig

- Don't upload configs if they already exist
- Use `service` instead of `deployment` for config generation
- Make `config` part of a `deployment`

## Bugs

- If the container count changes, it is mixing up stopping with replacing

## Naming

- Remove `Command::Builder` in favor of embedding commands
- Move `Command::Docker` to `Docker::CLI`
- Rename `Invocation` to `Command`
- Add tests for the DockerCLI classes

## Cleanup

- Is there something like `hosts_for_roles(roles)` needed?

## UX

- Make the console useful for debugging
  - I'd want to be able to connect to a host and execute steps as needed
