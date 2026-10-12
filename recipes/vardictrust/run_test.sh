#!/usr/bin/env bash
set -euo pipefail

echo "=== Verifying vardictrust installation in conda environment ==="

# 1. Binary presence
command -v vardictrust

# 2. Version check (asserts semantic version regex)
version_output="$(vardictrust --version)"
echo "Output: $version_output"
echo "$version_output" | grep -E "^vardictrust [0-9]+\.[0-9]+\.[0-9]+"

# 3. Help invocation
vardictrust --help | grep -i "Usage:"

# 4. Error-handling contract (invalid flag should exit with Clap usage error 2 without panic)
set +e
vardictrust --nonexistent-flag 2>/dev/null
status=$?
set -e
if [ "$status" -ne 2 ]; then
  echo "FAIL: Expected exit code 2 (usage error) on invalid flag, got $status" >&2
  exit 1
fi

echo "=== vardictrust conda smoke test passed successfully ==="
