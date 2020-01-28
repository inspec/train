#!/bin/bash

echo "--- dependencies"
. .expeditor/buildkite/cache_support.sh
install_cache_deps

echo "--- system details"
uname -a
ruby -v
bundle --version

echo "--- pull bundle cache"
pull_bundle

echo "--- bundle install"
bundle config --local path vendor/bundle
bundle install --jobs=7 --retry=3 --without tools integration

echo "--- push bundle cache"
push_bundle

echo "+++ bundle exec rake"
bundle exec rake ${RAKE_TASK:-}
