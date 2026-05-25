#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)
input_file="$repo_root/docs/architecture.mmd"
output_dir="${1:-$(mktemp -d)}"
output_file="$output_dir/architecture.svg"

if [[ ! -f "$input_file" ]]; then
  echo "Missing Mermaid source: $input_file" >&2
  exit 1
fi

mkdir -p "$output_dir"

if command -v mmdc >/dev/null 2>&1; then
  renderer=(mmdc)
elif command -v npx >/dev/null 2>&1; then
  renderer=(npx -y @mermaid-js/mermaid-cli@10.9.1)
else
  echo "Need either 'mmdc' or 'npx' with Node.js available to validate the diagram." >&2
  exit 1
fi

"${renderer[@]}" -i "$input_file" -o "$output_file"

echo "Rendered diagram to $output_file"