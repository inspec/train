#!/bin/bash

echo "--- system details"
uname -a
ruby -v
bundle --version

echo "--- bundle install"
bundle config --local path vendor/bundle
bundle install --jobs=7 --retry=3

echo "+++ bundle exec rake"
bundle exec rake ${RAKE_TASK:-}
