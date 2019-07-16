#!/bin/bash

echo "--- bundle install"
bundle install --jobs=7 --retry=3 --without tools maintenance deploy

echo "+++ bundle exec rake test"
bundle exec rake

