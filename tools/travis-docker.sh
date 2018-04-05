#!/usr/bin/env bash
set -e

# Skip this step for jobs that don't run exunit
test "${PRESET}" == "exunit" || exit 0

tools/travis-release.sh
docker build -f Dockerfile.release -t mongoose_push:release . 

DOCKERHUB_TAG="${TRAVIS_BRANCH//\//-}"

if [ "${TRAVIS_PULL_REQUEST}" != 'false' ]; then
    DOCKERHUB_TAG="PR-${TRAVIS_PULL_REQUEST}"
elif [ "${TRAVIS_BRANCH}" == 'master' ]; then
    DOCKERHUB_TAG="latest";
fi

TARGET_IMAGE="${DOCKERHUB_REPOSITORY}/mongoose-push:${DOCKERHUB_TAG}"

if [ "${TRAVIS_SECURE_ENV_VARS}" == 'true' ]; then
  docker login -u "${DOCKERHUB_USER}" -p "${DOCKERHUB_PASS}"
  docker tag mongoose_push:release "${TARGET_IMAGE}"
  docker push "${TARGET_IMAGE}"
fi
