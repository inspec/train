#!/bin/bash

set -ueo pipefail

echo "--- system details"
uname -a
ruby -v
bundle --version

echo "--- system environment"
env

echo "--- installing vault"
export VAULT_VERSION=1.13.0
export VAULT_HOME=$HOME/vault
curl --create-dirs -sSLo $VAULT_HOME/vault.zip https://releases.hashicorp.com/vault/$VAULT_VERSION/vault_${VAULT_VERSION}_linux_amd64.zip
unzip -o $VAULT_HOME/vault.zip -d $VAULT_HOME

if [ -n "${CI_ENABLE_COVERAGE:-}" ]; then
  echo "--- fetching Sonar token from vault"
  export SONAR_TOKEN=$($VAULT_HOME/vault kv get -field token secret/inspec/train)
fi

echo "--- bundle install"
bundle config set --local without tools integration
bundle install --jobs=7 --retry=3

echo "+++ bundle exec rake"
bundle exec rake ${RAKE_TASK:-}
RAKE_EXIT=$?

if [ -n "${CI_ENABLE_COVERAGE:-}" ]; then
  echo "--- installing sonarscanner"
  export SONAR_SCANNER_VERSION=6.1.0.4477
  export SONAR_SCANNER_HOME=$HOME/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-linux-x64
  curl --create-dirs -sSLo $HOME/.sonar/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux-x64.zip
  unzip -o $HOME/.sonar/sonar-scanner.zip -d $HOME/.sonar/
  export PATH=$SONAR_SCANNER_HOME/bin:$PATH
  export SONAR_SCANNER_OPTS="-server"

  # Delete the vendor/ directory. I've tried to exclude it using sonar.exclusions,
  # but that appears to get ignored, and we end up analyzing the gemfile install
  # which blows our analysis.
  echo "--- deleting installed gems"
  rm -rf vendor/

  # See sonar-project.properties for additional settings
  echo "--- running sonarscanner"
  sonar-scanner \
  -Dsonar.sources=. \
  -Dsonar.host.url=https://sonar.progress.com
fi

exit $RAKE_EXIT
