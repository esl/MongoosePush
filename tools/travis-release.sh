#!/bin/bash
set -e

mix local.hex --force
mix local.rebar --force

export MIX_ENV=prod 

mix do deps.get, release
tar -czf mongoose_push.tar.gz -C _build/${MIX_ENV}/rel/mongoose_push .
