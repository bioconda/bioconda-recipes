#!/bin/bash
set -eu -o pipefail

sed -i '' 's=/usr/bin/make=/usr/bin/env make=' ${RECIPE_DIR}/bin/goldrush

mkdir -p ${PREFIX}

meson --prefix ${PREFIX} build
cd build
ninja
ninja install

