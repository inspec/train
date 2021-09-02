#!/bin/bash

set -ueo pipefail

echo "--- system details"
uname -a
ruby -v
bundle --version

echo "--- system environment"
env

echo "--- bundle install"
bundle config set --local without tools integration
bundle install --jobs=7 --retry=3

echo "+++ bundle exec rake"
bundle exec rake

