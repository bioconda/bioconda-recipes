#!/usr/bin/env bash
set -euo pipefail

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

make -j${CPU_COUNT}

mkdir -p "${PREFIX}/bin"

if [[ -x "./taffy" ]]; then
  install -m 0755 ./taffy "${PREFIX}/bin/taffy"
elif [[ -x "./bin/taffy" ]]; then
  install -m 0755 ./bin/taffy "${PREFIX}/bin/taffy"
else
  echo "ERROR: taffy CLI binary not found after make"
  find . -maxdepth 3 -type f -name "taffy" -o -name "taffy*" -print
  exit 1
fi