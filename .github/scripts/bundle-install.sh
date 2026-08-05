#!/usr/bin/env bash
# Wrapper script for bundle install
# Works around git bare repository issues when invoked from certain environments
# (VS Code/Copilot sets GIT_CONFIG_* to enforce safe.bareRepository=explicit)

set -euo pipefail

cd "$(dirname "$0")/../.."

# Clear VS Code's git config overrides that break bundler's bare repo clones
unset GIT_CONFIG_PARAMETERS

if [[ -n "${GIT_CONFIG_COUNT:-}" ]]; then
  for ((i=0; i< GIT_CONFIG_COUNT; i++)); do
    unset "GIT_CONFIG_KEY_${i}" "GIT_CONFIG_VALUE_${i}"
  done
  unset GIT_CONFIG_COUNT
fi
echo "==> Running bundle install..."
bundle install "$@"
echo "==> bundle install completed successfully"
