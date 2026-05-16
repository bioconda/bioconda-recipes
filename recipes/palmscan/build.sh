#!/bin/bash
set -euo pipefail

cd src
make -j "${CPU_COUNT}"

mkdir -p "${PREFIX}/bin"
install -m 0755 ../bin/palmscan2 "${PREFIX}/bin/palmscan2"
