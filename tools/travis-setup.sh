#!/usr/bin/env bash
set -e

# Skip this setup for jobs that don't run exunit
test "${PRESET}" == "exunit" || exit 0

docker run -d -p 2197:2197 mobify/apns-http2-mock-server
docker run -d -p 443:443 rslota/fcm-http2-mock-server
