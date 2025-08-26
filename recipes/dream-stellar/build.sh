#!/bin/bash

set -eux


mkdir -p build
cd build
cmake ../.. -DCMAKE_BUILD_TYPE=Release -Wno-interference-size -D__STDC_FORMAT_MACROS" \
                -DCMAKE_INSTALL_PREFIX="${PREFIX}"
make -j"${CPU_COUNT}"
make install
cd ../..

cp "${RECIPE_DIR}/dream-stellar" "${PREFIX}/bin/dream-stellar"
chmod +x "${PREFIX}/bin/dream-stellar"
