#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"

install -v -m 0755 bin/INSTALL_annotations.sh "${PREFIX}/bin"

make install -j"${CPU_COUNT}"
