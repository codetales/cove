# TODO

- Split `StateDiff` into two individual entities for creation and starting/stopping

- Test for `GetExistingContainerDetails` when there are no existing containers (didn't return the right data type)
- `StateDiff` test: running existing containers should not be started
- Implement `StateDiff#containers_to_stop`

- Extract `Step`s from `ServiceUp` into their own classes

- Add good tests around the `Command::Builder` to make sure that the commands being created make sense
