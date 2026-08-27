#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"
binary="$(find . -maxdepth 1 -type f -name 'lightpanda-*' -print -quit)"
test -n "${binary}"
install -m 0755 "${binary}" "${PREFIX}/bin/lightpanda"
