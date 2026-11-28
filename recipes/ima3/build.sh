#!/bin/bash
set -eo pipefail

mkdir -p "${PREFIX}/bin"

make CC2="${CXX}" FLAGS="-O3 -fpermissive -Wno-register" -j"${CPU_COUNT}"

install -v -m 0755 IMa3 "${PREFIX}/bin"
