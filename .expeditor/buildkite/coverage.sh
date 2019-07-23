#!/bin/bash

set -ueo pipefail

echo "--- system details"
uname -a
ruby -v
bundle --version

echo "--- bundle install"
bundle install --jobs=7 --retry=3 --without tools integration

echo "+++ bundle exec rake"
export CI_NAME=Buildkite
export CI_BUILD_NUMBER=$BUILDKITE_BUILD_NUMBER
export CI_BUILD_URL=$BUILDKITE_BUILD_URL
export CI_BRANCH=$BUILDKITE_BRANCH

bundle exec rake

