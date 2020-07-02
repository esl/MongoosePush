# Running tests

One thing that you need to do *once* before running any tests is generating fake certificates for APNS/HTTPS (it doesn't matter which MIX_ENV you run this in):

```bash
mix certs.dev
```

Also, you'll need to have `docker-compose` installed and present in your path to run any tests.

## TL;DR

```bash
# Unit tests
MIX_ENV=test mix do test.env.up, test, test.env.down

# Integration tests
MIX_ENV=integration mix do test.env.up, test, test.env.down
```

## Basic tests (non-release)

Basic tests require FCM and APNS mock services to be present at the time of running the tests:

```bash
# We start the mocks
mix test.env.up

# Now we can just run tests
mix test

# Optionally we can shut the mocks down. If you want to rerun the tests, you may skip this step so that
# you don't need to re-invoke `mix test.env.up`. Mocks are being reset by each test separately,
# so you don't need to worry about their state.
mix test.env.down
```

## Integration tests (using production-grade release)

Integration tests can be run in exactly the same way as described above for "basic" tests, with one exception:
All Mix commands need to be invoked in the `MIX_ENV=integration` environment:

```bash
# We start the mocks AND MongoosePush docker container.
# This may take a few minutes on the first run, as the MongoosePush docker image needs
# to build from scratch. Subsequent runs should be much faster.
# You need to rerun this command each time you make changes in the app code,
# as MongoosePush needs to be rebuilt and redeployed!
MIX_ENV=integration mix test.env.up

# Now we can just run tests
MIX_ENV=integration mix test

# Optionally we can shut the mocks down. If you want to rerun tests, you may skip this step. To do that
# you don't need to re-invoke `mix test.env.up`. Mocks are being reset by each test separately,
# so you don't need to worry about their state.
MIX_ENV=integration mix test.env.down
```


## Test environment setup

* `mix test.env.up` - runs `docker-compose up -d --build` with the following compose files:
  * for `MIX_ENV=test` and `MIX_ENV=dev`: *test/docker/docker-compose.mocks.yml*
  * for `MIX_ENV=integration`: *test/docker/docker-compose.mocks.yml* and *test/docker/docker-compose.mpush.yml*
* `mix test.env.down` - runs `docker-compose down` on the same compose files as `mix test.env.up`
* `mix test.env.wait X` - waits up to X milliseconds for the services from `mix test.env.up` to become available. Prints an error if they don't.
