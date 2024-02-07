#!/bin/bash
set -eu -o pipefail

# Build ntSynt
mkdir -p ${PREFIX}/bin
meson setup build --prefix ${PREFIX} build
cd build
ninja install
