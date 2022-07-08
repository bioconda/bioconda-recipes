#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}

meson --prefix ${PREFIX} build
cd build
ninja
ninja install

