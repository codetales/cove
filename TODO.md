# TODO

## DeploymentConfig

- Wrap `Deployment` and `DeploymentConfig` into a package for versioning
- Mount configs
- Permissions of files/directories
- Use `service` instead of `deployment` for config generation?
- Tests should go through the whole flow and actually upload something

- Don't upload configs if they already exist

## Bugs

- Changing order of role/service definitions should not change the version

## Naming

- Is `Service` actually a `Stack` and `Role` is a `Service`? Is there an `Application` burried in there?
  - `ServicePlacement` and `ServiceConfig` would be the input to the `Deployment`
  - Or `Stack` and `Role`?
- Remove `Command::Builder` in favor of embedding commands
- Move `Command::Docker` to `Docker::CLI`
- Rename `Invocation` to `Command`
- Add tests for the DockerCLI classes
