#!/usr/bin/env bash
set -e

case "${PRESET}" in
  "exunit" )
    mix coveralls.travis
    ;;
  "dialyzer" )
    mkdir -p .dialyzer
    mix dialyzer
    ;;
  "credo" )
    mix credo --ignore design
    ;;
  * )
    echo "Unknown PRESET value" && exit 1
esac
