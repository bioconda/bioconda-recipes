#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"
binary=""
for candidate in ./lightpanda-*; do
  if [ -f "${candidate}" ]; then
    binary="${candidate}"
    break
  fi
done
test -n "${binary}"
install -m 0755 "${binary}" "${PREFIX}/bin/lightpanda"
